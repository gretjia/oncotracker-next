'use client';

import { useState, useRef } from 'react';
import Link from 'next/link';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Activity, FileSpreadsheet, Trash2, Pencil, Check, X, Upload, Loader2 } from 'lucide-react';
import { deletePatientAction, updatePatientAction, reUploadPatientData } from '@/app/actions/patient-actions';

interface PatientCardProps {
    patient: any;
}

export function PatientCard({ patient }: PatientCardProps) {
    const [isDeleted, setIsDeleted] = useState(false);
    const [isConfirming, setIsConfirming] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [isUploading, setIsUploading] = useState(false);
    const [familyName, setFamilyName] = useState(patient.family_name);
    const [givenName, setGivenName] = useState(patient.given_name);
    const [displayName, setDisplayName] = useState(`${patient.family_name} ${patient.given_name}`);
    const fileInputRef = useRef<HTMLInputElement>(null);

    if (isDeleted) return null;

    const handleSave = async () => {
        if (!familyName.trim()) {
            alert('姓不能为空');
            return;
        }
        setIsSaving(true);
        const result = await updatePatientAction(patient.id, familyName.trim(), givenName.trim());
        setIsSaving(false);
        if (result.success) {
            setDisplayName(`${familyName.trim()} ${givenName.trim()}`);
            setIsEditing(false);
        } else {
            alert('更新失败: ' + result.error);
        }
    };

    const handleCancel = () => {
        setFamilyName(patient.family_name);
        setGivenName(patient.given_name);
        setIsEditing(false);
    };

    const handleReUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setIsUploading(true);
        try {
            const formData = new FormData();
            formData.append('file', file);
            const result = await reUploadPatientData(patient.id, formData);
            if (result.success) {
                alert('数据更新成功！设置已保留。');
                window.location.reload(); // Refresh to show new data
            } else {
                alert('更新失败: ' + result.error);
            }
        } catch (err: any) {
            alert('上传失败: ' + err.message);
        } finally {
            setIsUploading(false);
            if (fileInputRef.current) {
                fileInputRef.current.value = ''; // Reset input
            }
        }
    };

    return (
        <Card className="hover:shadow-md transition-shadow">
            <CardContent className="p-4 md:p-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-slate-100 rounded-full flex items-center justify-center text-slate-500 font-bold shrink-0">
                        {familyName.charAt(0)}
                    </div>
                    <div className="min-w-0">
                        {isEditing ? (
                            <div className="flex items-center gap-2 flex-wrap">
                                <Input
                                    value={familyName}
                                    onChange={(e) => setFamilyName(e.target.value)}
                                    placeholder="姓"
                                    className="w-24 h-9 text-lg font-bold"
                                    autoFocus
                                />
                                <Input
                                    value={givenName}
                                    onChange={(e) => setGivenName(e.target.value)}
                                    placeholder="名"
                                    className="w-24 h-9 text-lg font-bold"
                                />
                                <Button
                                    size="sm"
                                    className="h-9 bg-emerald-600 hover:bg-emerald-700"
                                    onClick={handleSave}
                                    disabled={isSaving}
                                >
                                    <Check className="w-4 h-4" />
                                </Button>
                                <Button
                                    variant="ghost"
                                    size="sm"
                                    className="h-9"
                                    onClick={handleCancel}
                                    disabled={isSaving}
                                >
                                    <X className="w-4 h-4" />
                                </Button>
                            </div>
                        ) : (
                            <div className="flex items-center gap-2">
                                <h3 className="font-bold text-lg text-slate-800 truncate">
                                    {displayName}
                                </h3>
                                <Button
                                    variant="ghost"
                                    size="sm"
                                    className="h-7 w-7 p-0 text-slate-400 hover:text-blue-600"
                                    onClick={() => setIsEditing(true)}
                                    title="编辑姓名"
                                >
                                    <Pencil className="w-3.5 h-3.5" />
                                </Button>
                            </div>
                        )}
                        <div className="flex items-center gap-3 text-sm text-slate-500">
                            <span>{patient.mrn}</span>
                            <span className="w-1 h-1 bg-slate-300 rounded-full" />
                            <span>{patient.active ? '活跃' : '停用'}</span>
                        </div>
                    </div>
                </div>

                <div className="flex flex-wrap items-center gap-3 md:gap-4">
                    <div className="text-right mr-2 hidden md:block">
                        <div className="text-xs text-slate-400">添加日期</div>
                        {new Date(patient.created_at).toLocaleDateString('zh-CN')}
                    </div>
                    <Link href={`/journey?patientId=${patient.id}`}>
                        <Button variant="outline" size="default" className="gap-2 min-h-[44px]">
                            <Activity className="w-4 h-4" /> 查看病程
                        </Button>
                    </Link>
                    <Link href={`/manage-data?patientId=${patient.id}`}>
                        <Button variant="outline" size="default" className="gap-2 text-blue-600 border-blue-200 hover:bg-blue-50 min-h-[44px]">
                            <FileSpreadsheet className="w-4 h-4" /> 编辑数据
                        </Button>
                    </Link>
                    <div className="relative">
                        <input
                            ref={fileInputRef}
                            type="file"
                            accept=".xlsx,.xls"
                            title="选择患者数据文件"
                            className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                            onChange={handleReUpload}
                            disabled={isUploading}
                        />
                        <Button
                            variant="outline"
                            size="default"
                            className="gap-2 text-emerald-600 border-emerald-200 hover:bg-emerald-50 min-h-[44px]"
                            disabled={isUploading}
                        >
                            {isUploading ? (
                                <><Loader2 className="w-4 h-4 animate-spin" /> 上传中...</>
                            ) : (
                                <><Upload className="w-4 h-4" /> 更新数据</>
                            )}
                        </Button>
                    </div>
                    {isConfirming ? (
                        <div className="flex items-center gap-2 animate-in fade-in slide-in-from-right-2 duration-200">
                            <span className="text-xs font-bold text-red-600">确认删除?</span>
                            <Button
                                variant="destructive"
                                size="sm"
                                className="h-9 px-3 text-sm min-h-[44px]"
                                onClick={async () => {
                                    const result = await deletePatientAction(patient.id);
                                    if (result.success) {
                                        setIsDeleted(true);
                                    } else {
                                        alert('删除失败: ' + result.error);
                                        setIsConfirming(false);
                                    }
                                }}
                            >
                                确定
                            </Button>
                            <Button
                                variant="ghost"
                                size="sm"
                                className="h-9 px-3 text-sm min-h-[44px]"
                                onClick={() => setIsConfirming(false)}
                            >
                                取消
                            </Button>
                        </div>
                    ) : (
                        <Button
                            variant="ghost"
                            size="default"
                            className="text-red-500 hover:text-red-700 hover:bg-red-50 min-h-[44px]"
                            onClick={() => setIsConfirming(true)}
                        >
                            <Trash2 className="w-4 h-4" />
                        </Button>
                    )}
                </div>
            </CardContent>
        </Card>
    );
}
