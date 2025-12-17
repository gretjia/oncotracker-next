# Cloud Version Changelog

## 2025-12-17 - Cloud Deployment & Chinese Localization

### 🌐 Cloud Infrastructure

- **Domain Setup**: Deployed to `快点好.com` (xn--5us92m0xp.com)
- **HTTPS**: SSL certificates via Let's Encrypt
- **Server**: Alibaba Cloud ECS with PM2 cluster mode
- **Nginx Proxy**: Configured for Next.js and Supabase routing

### 🇨🇳 Complete Chinese Localization

All UI text translated to Simplified Chinese:

| Page | Key Translations |
|------|-----------------|
| **首页** | 患者入口、医生入口、管理员入口 |
| **登录/注册** | 邮箱、密码、登录、注册 |
| **医生仪表盘** | 我的患者、添加患者、退出登录 |
| **患者卡片** | 查看病程、编辑数据、确认删除 |
| **添加患者** | 姓名、上传初始数据、深度分析已启用 |
| **患者仪表盘** | 您的治疗旅程、打开可视化工具 |
| **管理员仪表盘** | 待审批用户、通过、拒绝 |
| **数据管理器** | 导入、保存更改、添加行、添加指标 |

### ✏️ Edit Patient Feature

- **Inline Editing**: Click pencil icon ✏️ next to patient name
- **Separate Fields**: Edit family name (姓) and given name (名) independently
- **Chinese Names**: Now supports names like 高雨秀, 张莉
- **Server Action**: `updatePatientAction` updates database and user metadata

### 📱 iPad Compatibility

- **Viewport**: Added `viewportFit: cover` for safe area handling
- **Touch Targets**: 44px minimum height for all buttons
- **Responsive Layout**: Flex-wrap for tablet screens
- **Input Zoom Prevention**: 16px font-size on inputs

### 🔧 Bug Fixes

- **NEXT_REDIRECT Error**: Fixed console noise from redirect() in login flow
- **Form Accessibility**: Added `name` and `autoComplete` attributes to login form
- **Deep Analysis Default**: Removed toggle, now always enabled for patient uploads

### 🗄️ Database Changes

- No schema changes - all features use existing `patients` table
- `family_name` and `given_name` columns now store Chinese characters

### 📁 Files Modified

```
app/
├── actions/patient-actions.ts    # Added updatePatientAction
├── auth/login/page.tsx           # Chinese + NEXT_REDIRECT fix
├── auth/register/page.tsx        # Chinese localization
├── dashboard/doctor/
│   ├── page.tsx                  # Chinese labels
│   ├── add-patient/page.tsx      # Chinese + deep analysis default
│   └── components/PatientCard.tsx # Chinese + edit mode
├── dashboard/patient/page.tsx    # Chinese localization
├── dashboard/supervisor/page.tsx # Chinese localization
├── globals.css                   # iPad safe area + touch targets
├── journey/page.tsx              # Chinese metadata
├── layout.tsx                    # Viewport + Chinese metadata
├── manage-data/page.tsx          # Chinese localization
└── page.tsx                      # Chinese homepage
```

### 🚀 Deployment

```bash
# Build locally (uses .env.production)
npm run build

# Package and upload
tar -czf build.tar.gz .next public next.config.ts package.json
scp -i deployment/oncotracker.pem build.tar.gz root@8.222.155.67:/opt/oncotracker/

# Deploy on server
ssh root@8.222.155.67
cd /opt/oncotracker && tar -xzf build.tar.gz && pm2 restart oncotracker-next
```
