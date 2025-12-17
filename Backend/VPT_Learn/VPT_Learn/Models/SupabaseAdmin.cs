namespace VPT_Learn.Models
{
    public static class SupabaseAdmin
    {
        public static Supabase.Client Create()
        {
            var client = new Supabase.Client(
                Environment.GetEnvironmentVariable("SUPABASE_URL")!,
                Environment.GetEnvironmentVariable("SUPABASE_SERVICE_ROLE_KEY")!
            );
            client.AdminAuth(Environment.GetEnvironmentVariable("SUPABASE_SERVICE_ROLE_KEY")!);
            return client;
        }
    }

}
