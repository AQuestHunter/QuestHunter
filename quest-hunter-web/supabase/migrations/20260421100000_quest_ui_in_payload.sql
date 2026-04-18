-- Include optional quests.body.ui in player payload (buttons, labels, finale card copy).

create or replace function public.get_player_quest_payload(p_quest_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  q public.quests%rowtype;
  b jsonb;
  puzzles jsonb := '[]'::jsonb;
begin
  if auth.uid() is null then
    return jsonb_build_object('error', 'auth');
  end if;

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('error', 'not_found');
  end if;

  if coalesce(q.archived, false) then
    return jsonb_build_object('error', 'not_available');
  end if;

  if not (
    q.is_published
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  ) then
    return jsonb_build_object('error', 'not_available');
  end if;

  b := q.body;

  select coalesce(
           (
             select jsonb_agg(e - 'answer' - 'xp')
               from (
                      select jsonb_array_elements(coalesce(b -> 'puzzles', '[]'::jsonb)) as e
                    ) as elems
           ),
           '[]'::jsonb
         )
    into puzzles;

  return jsonb_build_object(
    'intro', coalesce(b ->> 'intro', ''),
    'puzzles', puzzles,
    'finalePrompt', coalesce(b ->> 'finalePrompt', ''),
    'ui', coalesce(b -> 'ui', '{}'::jsonb)
  );
end;
$$;
