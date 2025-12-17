import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'standalone',  // Required for production deployment
  async rewrites() {
    // Only rewrite to local Supabase in development
    // In production, use the actual NEXT_PUBLIC_SUPABASE_URL from env
    if (process.env.NODE_ENV === 'development') {
      return [
        {
          source: '/supabase/:path*',
          destination: 'http://127.0.0.1:54321/:path*',
        },
      ]
    }
    return [];
  },
};

export default nextConfig;
