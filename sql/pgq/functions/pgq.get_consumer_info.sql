
-------------------------------------------------------------------------
create or replace function pgq.get_consumer_info()
returns setof pgq.ret_consumer_info as $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(0)
--
--      Desc
--
-- Parameters:
--      arg - desc
--
-- Returns:
--      desc
-- ----------------------------------------------------------------------
declare
    ret  pgq.ret_consumer_info%rowtype;
    i    record;
begin
    for i in select queue_name from pgq.queue order by 1
    loop
        for ret in
            select * from pgq.get_consumer_info(i.queue_name)
        loop
            return next ret;
        end loop;
    end loop;
    return;
end;
$$ language plpgsql security definer;


-------------------------------------------------------------------------
create or replace function pgq.get_consumer_info(x_queue_name text)
returns setof pgq.ret_consumer_info as $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(1)
--
--      Desc
--
-- Parameters:
--      arg - desc
--
-- Returns:
--      desc
-- ----------------------------------------------------------------------
declare
    ret  pgq.ret_consumer_info%rowtype;
    tmp record;
begin
    for tmp in
        select queue_name, co_name
          from pgq.queue, pgq.consumer, pgq.subscription
         where queue_id = sub_queue
           and co_id = sub_consumer
           and queue_name = x_queue_name
         order by 1, 2
    loop
        for ret in
            select * from pgq.get_consumer_info(tmp.queue_name, tmp.co_name)
        loop
            return next ret;
        end loop;
    end loop;
    return;
end;
$$ language plpgsql security definer;


------------------------------------------------------------------------
create or replace function pgq.get_consumer_info(
    x_queue_name text,
    x_consumer_name text)
returns setof pgq.ret_consumer_info as $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(2)
--
--      Get info about particular consumer on particular queue.
--
-- Parameters:
--      x_queue_name        - name of a queue.
--      x_consumer_name     - name of a consumer
--
-- Returns:
--      info
-- ----------------------------------------------------------------------
declare
    ret  pgq.ret_consumer_info%rowtype;
begin
    for ret in 
        select queue_name, co_name,
               current_timestamp - tick_time as lag,
               current_timestamp - sub_active as last_seen
          from pgq.subscription, pgq.tick, pgq.queue, pgq.consumer
         where tick_id = sub_last_tick
           and queue_id = sub_queue
           and tick_queue = sub_queue
           and co_id = sub_consumer
           and queue_name = x_queue_name
           and co_name = x_consumer_name
         order by 1,2
    loop
        return next ret;
    end loop;
    return;
end;
$$ language plpgsql security definer;

