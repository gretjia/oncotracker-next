'use client';

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Activity, User, Stethoscope, ShieldCheck } from 'lucide-react';

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-slate-100 flex flex-col items-center justify-center p-4">
      <div className="max-w-4xl w-full space-y-8">

        {/* Header */}
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center gap-3 mb-6">
            <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center text-white shadow-lg">
              <Activity className="w-8 h-8" />
            </div>
            <h1 className="text-4xl font-bold text-slate-900 tracking-tight">OncoTracker</h1>
          </div>
          <p className="text-xl text-slate-600 max-w-2xl mx-auto">
            专为现代肿瘤诊疗打造的患者病程可视化平台。
          </p>
        </div>

        {/* Login Cards */}
        <div className="grid md:grid-cols-2 gap-6 mt-12">

          {/* Patient Portal */}
          <Card className="border-slate-200 shadow-md hover:shadow-xl transition-shadow duration-300">
            <CardHeader className="text-center pb-2">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4 text-blue-600">
                <User className="w-8 h-8" />
              </div>
              <CardTitle className="text-2xl text-slate-800">患者入口</CardTitle>
              <CardDescription>查看您的治疗旅程和病历</CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-3 pt-4">
              <Link href="/auth/login?role=patient" className="w-full">
                <Button className="w-full h-12 text-lg bg-blue-600 hover:bg-blue-700">
                  患者登录
                </Button>
              </Link>
              <div className="text-center text-sm text-slate-500 mt-2">
                新用户？ <Link href="/auth/register?role=patient" className="text-blue-600 hover:underline">创建账号</Link>
              </div>
            </CardContent>
          </Card>

          {/* Provider Portal */}
          <Card className="border-slate-200 shadow-md hover:shadow-xl transition-shadow duration-300">
            <CardHeader className="text-center pb-2">
              <div className="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-4 text-emerald-600">
                <Stethoscope className="w-8 h-8" />
              </div>
              <CardTitle className="text-2xl text-slate-800">医生入口</CardTitle>
              <CardDescription>面向医生和医护人员</CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-3 pt-4">
              <Link href="/auth/login?role=doctor" className="w-full">
                <Button variant="outline" className="w-full h-12 text-lg border-emerald-200 text-emerald-700 hover:bg-emerald-50 hover:text-emerald-800 hover:border-emerald-300">
                  医生登录
                </Button>
              </Link>
              <div className="text-center text-sm text-slate-500 mt-2">
                <Link href="/auth/login?role=supervisor" className="flex items-center justify-center gap-1 hover:text-slate-800 transition-colors">
                  <ShieldCheck className="w-3 h-3" /> 管理员入口
                </Link>
              </div>
            </CardContent>
          </Card>

        </div>

        {/* Footer */}
        <div className="text-center text-slate-400 text-sm mt-12">
          &copy; {new Date().getFullYear()} OncoTracker. 安全合规。
        </div>
      </div>
    </div>
  );
}
