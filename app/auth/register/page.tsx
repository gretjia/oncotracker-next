'use client';

import { useState, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from '@/components/ui/card';
import { Activity, ArrowLeft } from 'lucide-react';

function RegisterForm() {
    const searchParams = useSearchParams();
    const router = useRouter();
    const role = searchParams.get('role') || 'patient';
    const [isLoading, setIsLoading] = useState(false);

    // Form State
    const [formData, setFormData] = useState({
        email: '',
        password: '',
        fullName: '',
        mrn: '', // Patient only
        license: '', // Doctor only
        specialty: '', // Doctor only
    });

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({ ...formData, [e.target.id]: e.target.value });
    };

    const handleRegister = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);

        // TODO: Implement actual Supabase registration here
        console.log("Registering as", role, formData);

        // Simulate delay
        setTimeout(() => {
            setIsLoading(false);
            // Redirect to pending approval or dashboard
            alert("账户已创建！请等待管理员审核。");
            router.push('/');
        }, 1000);
    };

    const roleTitle = role === 'doctor' ? '医生' : '患者';

    return (
        <Card className="w-full max-w-md border-slate-200 shadow-lg">
            <CardHeader className="space-y-1">
                <div className="flex items-center justify-between">
                    <Link href="/" className="text-slate-400 hover:text-slate-600 transition-colors">
                        <ArrowLeft className="w-5 h-5" />
                    </Link>
                    <div className="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center text-white">
                        <Activity className="w-6 h-6" />
                    </div>
                    <div className="w-5" />
                </div>
                <CardTitle className="text-2xl font-bold text-center pt-4">创建{roleTitle}账户</CardTitle>
                <CardDescription className="text-center">
                    请填写您的信息以申请访问权限
                </CardDescription>
            </CardHeader>
            <CardContent>
                <form onSubmit={handleRegister} className="space-y-4">
                    <div className="space-y-2">
                        <Label htmlFor="fullName">姓名</Label>
                        <Input id="fullName" placeholder="张三" required value={formData.fullName} onChange={handleChange} />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="email">邮箱</Label>
                        <Input id="email" type="email" placeholder="name@example.com" required value={formData.email} onChange={handleChange} />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="password">密码</Label>
                        <Input id="password" type="password" required value={formData.password} onChange={handleChange} />
                    </div>

                    {role === 'patient' && (
                        <div className="space-y-2">
                            <Label htmlFor="mrn">病历号 (MRN)</Label>
                            <Input id="mrn" placeholder="MRN-12345" value={formData.mrn} onChange={handleChange} />
                        </div>
                    )}

                    {role === 'doctor' && (
                        <>
                            <div className="space-y-2">
                                <Label htmlFor="specialty">专科</Label>
                                <Input id="specialty" placeholder="肿瘤科" value={formData.specialty} onChange={handleChange} />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="license">执业证书号</Label>
                                <Input id="license" placeholder="LIC-12345" value={formData.license} onChange={handleChange} />
                            </div>
                        </>
                    )}

                    <Button type="submit" className="w-full bg-blue-600 hover:bg-blue-700" disabled={isLoading}>
                        {isLoading ? "创建中..." : "创建账户"}
                    </Button>
                </form>
            </CardContent>
            <CardFooter className="flex justify-center">
                <div className="text-sm text-slate-500">
                    已有账号？ <Link href={`/auth/login?role=${role}`} className="text-blue-600 hover:underline">登录</Link>
                </div>
            </CardFooter>
        </Card>
    );
}

export default function RegisterPage() {
    return (
        <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
            <Suspense fallback={<div>加载中...</div>}>
                <RegisterForm />
            </Suspense>
        </div>
    );
}
