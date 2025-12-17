'use client';

import Link from 'next/link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Activity, User, Calendar, FileText, LogOut } from 'lucide-react';

export default function PatientDashboard() {
    // Mock Data
    const patientName = "张莉 (Zhang Li)";
    const assignedDoctor = "Dr. SciX";
    const nextAppointment = "Dec 15, 2024 at 10:00 AM";

    return (
        <div className="min-h-screen bg-slate-50 flex flex-col">
            {/* Navbar */}
            <header className="bg-white border-b border-slate-200 h-16 flex items-center justify-between px-6 shadow-sm">
                <div className="flex items-center gap-2">
                    <div className="w-8 h-8 bg-blue-600 rounded flex items-center justify-center text-white">
                        <Activity className="w-5 h-5" />
                    </div>
                    <span className="font-bold text-slate-800 text-lg">OncoTracker</span>
                </div>
                <div className="flex items-center gap-4">
                    <span className="text-slate-600 text-sm">您好，{patientName}</span>
                    <Link href="/">
                        <Button variant="ghost" size="sm" className="text-slate-500 hover:text-red-600">
                            <LogOut className="w-4 h-4 mr-2" /> 退出登录
                        </Button>
                    </Link>
                </div>
            </header>

            {/* Main Content */}
            <main className="flex-1 p-6 max-w-6xl mx-auto w-full space-y-6">
                <h1 className="text-3xl font-bold text-slate-900">患者中心</h1>

                <div className="grid md:grid-cols-3 gap-6">
                    {/* Profile Card */}
                    <Card>
                        <CardHeader className="flex flex-row items-center gap-4">
                            <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-blue-600">
                                <User className="w-6 h-6" />
                            </div>
                            <div>
                                <CardTitle>我的资料</CardTitle>
                                <CardDescription>个人信息</CardDescription>
                            </div>
                        </CardHeader>
                        <CardContent className="space-y-2 text-sm">
                            <div className="flex justify-between border-b pb-2">
                                <span className="text-slate-500">姓名</span>
                                <span className="font-medium">{patientName}</span>
                            </div>
                            <div className="flex justify-between border-b pb-2">
                                <span className="text-slate-500">病历号</span>
                                <span className="font-medium">MRN-ZHANG-001</span>
                            </div>
                            <div className="flex justify-between pt-2">
                                <span className="text-slate-500">主治医生</span>
                                <span className="font-medium">{assignedDoctor}</span>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Journey Status */}
                    <Card className="md:col-span-2 bg-gradient-to-br from-blue-600 to-indigo-700 text-white border-none shadow-lg">
                        <CardHeader>
                            <CardTitle className="text-2xl">您的治疗旅程</CardTitle>
                            <CardDescription className="text-blue-100">跟踪进展、查看时间线、分析指标。</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <div className="flex items-center gap-4 mt-4">
                                <Link href="/journey">
                                    <Button className="bg-white text-blue-700 hover:bg-blue-50 border-none text-lg px-8 py-6 h-auto shadow-md transition-transform hover:scale-105">
                                        <Activity className="w-5 h-5 mr-2" /> 打开可视化工具
                                    </Button>
                                </Link>
                                <div className="text-blue-100 text-sm max-w-xs">
                                    上次更新: 今天 9:00
                                </div>
                            </div>
                        </CardContent>
                    </Card>
                </div>

                <div className="grid md:grid-cols-2 gap-6">
                    {/* Appointments */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Calendar className="w-5 h-5 text-slate-500" /> 即将到来的预约
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="p-4 bg-slate-50 rounded-lg border border-slate-100 flex items-start gap-4">
                                <div className="bg-white p-2 rounded border border-slate-200 text-center min-w-[60px]">
                                    <div className="text-xs text-slate-500 uppercase font-bold">Dec</div>
                                    <div className="text-xl font-bold text-slate-900">15</div>
                                </div>
                                <div>
                                    <h4 className="font-semibold text-slate-800">复诊</h4>
                                    <p className="text-sm text-slate-500">{assignedDoctor}</p>
                                    <p className="text-xs text-slate-400 mt-1">10:00 AM - 10:30 AM</p>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Documents */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <FileText className="w-5 h-5 text-slate-500" /> 最近文档
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-3">
                            <div className="flex items-center justify-between p-3 hover:bg-slate-50 rounded-lg transition-colors cursor-pointer border border-transparent hover:border-slate-100">
                                <div className="flex items-center gap-3">
                                    <FileText className="w-4 h-4 text-blue-500" />
                                    <span className="text-sm font-medium text-slate-700">血液检查报告.pdf</span>
                                </div>
                                <span className="text-xs text-slate-400">Nov 28</span>
                            </div>
                            <div className="flex items-center justify-between p-3 hover:bg-slate-50 rounded-lg transition-colors cursor-pointer border border-transparent hover:border-slate-100">
                                <div className="flex items-center gap-3">
                                    <FileText className="w-4 h-4 text-blue-500" />
                                    <span className="text-sm font-medium text-slate-700">出院小结.pdf</span>
                                </div>
                                <span className="text-xs text-slate-400">Nov 15</span>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </main >
        </div >
    );
}
