import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const cors = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-cron-secret', 'Content-Type': 'application/json' };
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: cors });
const dateKey = (d: Date) => new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Paris', year: 'numeric', month: '2-digit', day: '2-digit' }).format(d);
const parisParts = (d: Date) => new Intl.DateTimeFormat('en-GB', { timeZone: 'Europe/Paris', weekday: 'short', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).formatToParts(d);
const escapeHtml = (s: unknown) => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]!));

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  const secret = Deno.env.get('BRIEFING_CRON_SECRET');
  if (!secret || req.headers.get('x-cron-secret') !== secret) return json({ error: 'Unauthorized' }, 401);
  const parts = parisParts(new Date());
  const local = Object.fromEntries(parts.map(p => [p.type, p.value]));
  // The scheduler may invoke this every 15 minutes; only send at 08:00 Paris time, Mon–Fri.
  if (local.hour !== '08' || local.minute !== '00' || ['Sat', 'Sun'].includes(local.weekday)) return json({ skipped: true, reason: 'Outside weekday 08:00 Europe/Paris window' });

  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
  const resendKey = Deno.env.get('RESEND_API_KEY');
  const from = Deno.env.get('BRIEFING_FROM_EMAIL');
  if (!resendKey || !from) return json({ error: 'Missing RESEND_API_KEY or BRIEFING_FROM_EMAIL' }, 500);

  const { data: projects, error } = await supabase.from('projects').select('id,name,description,budget,project_data,project_members(email,full_name,role)').neq('status', 'Terminé');
  if (error) return json({ error: error.message }, 500);
  const today = dateKey(new Date());
  const weekEndDate = new Date(); weekEndDate.setDate(weekEndDate.getDate() + (7 - ((weekEndDate.getDay() + 6) % 7)));
  const weekEnd = dateKey(weekEndDate);
  let sent = 0; const failures: string[] = [];

  for (const project of projects ?? []) {
    const pdata = (project.project_data ?? {}) as Record<string, unknown>;
    const tasks = Array.isArray(pdata.tasks) ? pdata.tasks as Record<string, unknown>[] : [];
    const members = Array.isArray(project.project_members) ? project.project_members as Record<string, unknown>[] : [];
    const recipients = [...new Set(members.map(m => String(m.email ?? '').trim().toLowerCase()).filter(e => e.includes('@')))];
    const dueToday = tasks.filter(t => String(t.due ?? '') === today && !t.done);
    const dueWeek = tasks.filter(t => String(t.due ?? '') >= today && String(t.due ?? '') <= weekEnd && !t.done);
    const late = tasks.filter(t => String(t.due ?? '') && String(t.due) < today && !t.done);
    const completed = tasks.filter(t => t.done);
    if (!recipients.length || (!dueToday.length && !dueWeek.length && !late.length)) continue;

    for (const email of recipients) {
      const { data: existing } = await supabase.from('daily_briefing_logs').select('id').eq('project_id', project.id).eq('recipient_email', email).eq('briefing_date', today).maybeSingle();
      if (existing) continue;
      const list = (items: Record<string, unknown>[]) => items.length ? `<ul>${items.map(t => `<li><b>${escapeHtml(t.title)}</b> — ${escapeHtml(t.due || 'Sans date')} · ${escapeHtml(t.owner || 'Non assigné')}</li>`).join('')}</ul>` : '<p>Aucun élément.</p>';
      const html = `<div style="font-family:Arial,sans-serif;color:#242033;max-width:640px;margin:auto"><div style="background:#171326;color:white;padding:24px;border-radius:16px"><p style="color:#bba7ff;letter-spacing:2px">UX STUDIO · BRIEFING QUOTIDIEN</p><h1 style="margin:8px 0">${escapeHtml(project.name)}</h1><p>${today} · Bonjour ${escapeHtml(members.find(m => String(m.email).toLowerCase() === email)?.full_name || '')}</p></div><h2>À faire aujourd’hui</h2>${list(dueToday)}<h2>Cette semaine</h2>${list(dueWeek)}<h2>En retard</h2>${list(late)}<h2>Terminées</h2><p>${completed.length} tâche(s) terminée(s) sur ${tasks.length}.</p><p style="color:#777;font-size:12px">Message automatique généré par UX Studio.</p></div>`;
      try {
        const response = await fetch('https://api.resend.com/emails', { method: 'POST', headers: { Authorization: `Bearer ${resendKey}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ from, to: [email], subject: `UX Studio · ${project.name} — briefing du ${today}`, html }) });
        const payload = await response.json();
        if (!response.ok) throw new Error(payload.message || 'Resend error');
        await supabase.from('daily_briefing_logs').insert({ project_id: project.id, recipient_email: email, briefing_date: today, status: 'sent', provider_id: payload.id });
        sent++;
      } catch (e) {
        const message = e instanceof Error ? e.message : 'Unknown error'; failures.push(`${email}: ${message}`);
        await supabase.from('daily_briefing_logs').insert({ project_id: project.id, recipient_email: email, briefing_date: today, status: 'failed', error: message });
      }
    }
  }
  return json({ sent, failures, date: today });
});
