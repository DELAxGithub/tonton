CREATE OR REPLACE FUNCTION public.delete_user()
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  DELETE FROM auth.users WHERE id = auth.uid();
$$;

GRANT EXECUTE ON FUNCTION public.delete_user() TO authenticated;
