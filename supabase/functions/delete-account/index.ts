import {createClient} from 'https://esm.sh/@supabase/supabase-js@2'

const cors={
  'Access-Control-Allow-Origin':'*',
  'Access-Control-Allow-Headers':'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods':'POST, OPTIONS',
  'Content-Type':'application/json',
}
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:cors})

Deno.serve(async(req)=>{
  if(req.method==='OPTIONS')return new Response('ok',{headers:cors})
  if(req.method!=='POST')return json({error:'method_not_allowed'},405)
  const auth=req.headers.get('Authorization')
  if(!auth)return json({error:'unauthorized'},401)
  const url=Deno.env.get('SUPABASE_URL')
  const anon=Deno.env.get('SUPABASE_ANON_KEY')
  const service=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if(!url||!anon||!service)return json({error:'server_not_configured'},500)

  const userClient=createClient(url,anon,{global:{headers:{Authorization:auth}}})
  const {data:{user},error:userError}=await userClient.auth.getUser()
  if(userError||!user)return json({error:'unauthorized'},401)

  const admin=createClient(url,service)
  // Ordered and retry-safe: if a later step fails, a second request can continue deleting what remains.
  for(const table of ['sync_changes','sync_state','recurring_payments','transactions','budgets','goals','debts','accounts']){
    const {error}=await admin.from(table).delete().eq('user_id',user.id)
    if(error)return json({error:'delete_failed',stage:table},500)
  }
  const {error:profileError}=await admin.from('profiles').delete().eq('id',user.id)
  if(profileError)return json({error:'delete_failed',stage:'profiles'},500)
  const {error:authError}=await admin.auth.admin.deleteUser(user.id)
  if(authError)return json({error:'delete_failed',stage:'auth'},500)
  return json({ok:true})
})
