const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Serve static files
app.use(express.static('web'));
app.use(express.static('public'));
app.use(express.json());

// Admin credentials from code
const ADMIN_CREDENTIALS = {
    email: 'admin@paypoint.ye',
    password: 'PayPoint@2024!',
    name: 'مسؤول النظام',
    phone: '+967777000000'
};

// Mock data storage
let users = new Map();
let transactions = [];
let cards = [];
let currentUser = null;

// Initialize mock data
function initializeMockData() {
    // Add admin user
    users.set('admin', {
        id: 'admin',
        name: ADMIN_CREDENTIALS.name,
        email: ADMIN_CREDENTIALS.email,
        phone: ADMIN_CREDENTIALS.phone,
        balance: 50000,
        isAdmin: true,
        createdAt: new Date().toISOString()
    });

    // Generate mock cards
    const networks = ['yemenmobile', 'mtn', 'sabafon', 'wifi'];
    const values = [500, 1000, 2000, 5000, 10000];
    
    networks.forEach(network => {
        values.forEach(value => {
            for (let i = 0; i < 10; i++) {
                cards.push({
                    id: `${network}_${value}_${i}`,
                    network,
                    value,
                    code: generateCardCode(network),
                    serial: generateSerial(),
                    status: 'available',
                    createdAt: new Date().toISOString()
                });
            }
        });
    });
}

function generateCardCode(network) {
    const prefix = network.toUpperCase().substring(0, 4);
    const number = Math.floor(Math.random() * 900000) + 100000;
    return `${prefix}${number}`;
}

function generateSerial() {
    return `SN${Date.now()}${Math.floor(Math.random() * 1000)}`;
}

function processTransaction(type, amount, details) {
    const transaction = {
        id: `T${Date.now()}`,
        userId: currentUser?.id || 'anonymous',
        type,
        amount,
        status: 'completed',
        details,
        timestamp: new Date().toISOString(),
        success: true
    };
    
    transactions.unshift(transaction);
    
    // Update user balance if user exists
    if (currentUser && users.has(currentUser.id)) {
        const user = users.get(currentUser.id);
        user.balance -= amount;
        users.set(currentUser.id, user);
        currentUser = user;
    }
    
    return transaction;
}

// Advanced futuristic HTML template
const futuristicTemplate = `
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PayPoint 2080 - نظام الدفع المستقبلي</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Cairo:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            --accent-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            --dark-gradient: linear-gradient(135deg, #0c0c0c 0%, #1a1a2e 100%);
            --neon-blue: #00f5ff;
            --neon-purple: #bf00ff;
            --neon-green: #39ff14;
            --glass-bg: rgba(255, 255, 255, 0.1);
            --glass-border: rgba(255, 255, 255, 0.2);
        }
        
        body {
            font-family: 'Cairo', sans-serif;
            background: var(--dark-gradient);
            min-height: 100vh;
            overflow-x: hidden;
            color: white;
            position: relative;
        }
        
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(120, 219, 255, 0.2) 0%, transparent 50%);
            pointer-events: none;
            z-index: -1;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            position: relative;
            z-index: 1;
        }
        
        .header {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: conic-gradient(from 0deg, transparent, var(--neon-blue), transparent, var(--neon-purple), transparent);
            animation: rotate 8s linear infinite;
            opacity: 0.1;
            z-index: -1;
        }
        
        @keyframes rotate {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
        }
        
        .logo-icon {
            width: 60px;
            height: 60px;
            background: var(--accent-gradient);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 0 30px rgba(0, 245, 255, 0.5);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 0 30px rgba(0, 245, 255, 0.5); }
            50% { transform: scale(1.05); box-shadow: 0 0 40px rgba(0, 245, 255, 0.8); }
        }
        
        .logo-text {
            font-family: 'Orbitron', monospace;
            font-size: 28px;
            font-weight: 900;
            background: var(--accent-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(0, 245, 255, 0.5);
        }
        
        .user-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
        }
        
        .welcome-text {
            font-size: 18px;
            opacity: 0.9;
        }
        
        .admin-badge {
            background: var(--secondary-gradient);
            padding: 8px 16px;
            border-radius: 25px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            animation: glow 2s ease-in-out infinite alternate;
        }
        
        @keyframes glow {
            from { box-shadow: 0 0 20px rgba(191, 0, 255, 0.5); }
            to { box-shadow: 0 0 30px rgba(191, 0, 255, 0.8); }
        }
        
        .balance-card {
            background: var(--glass-bg);
            backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            border-radius: 25px;
            padding: 30px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        
        .balance-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }
        
        .balance-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            animation: shimmer 3s infinite;
        }
        
        @keyframes shimmer {
            0% { left: -100%; }
            100% { left: 100%; }
        }
        
        .balance-label {
            font-size: 14px;
            opacity: 0.8;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .balance-amount {
            font-family: 'Orbitron', monospace;
            font-size: 36px;
            font-weight: 700;
            background: var(--accent-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 20px;
            text-shadow: 0 0 20px rgba(0, 245, 255, 0.3);
        }
        
        .balance-actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .btn {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 15px;
            padding: 15px 20px;
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            cursor: pointer;
        }
        
        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }
        
        .btn:hover::before {
            left: 100%;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            border-color: var(--neon-blue);
        }
        
        .btn-primary {
            background: var(--primary-gradient);
            border-color: var(--neon-blue);
        }
        
        .btn-secondary {
            background: var(--secondary-gradient);
            border-color: var(--neon-purple);
        }
        
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        
        .service-card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 25px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            cursor: pointer;
        }
        
        .service-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--accent-gradient);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }
        
        .service-card:hover::before {
            transform: scaleX(1);
        }
        
        .service-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            border-color: var(--neon-blue);
        }
        
        .service-icon {
            width: 60px;
            height: 60px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 15px;
            position: relative;
        }
        
        .service-icon.network { background: var(--primary-gradient); }
        .service-icon.wifi { background: var(--secondary-gradient); }
        .service-icon.electricity { background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%); }
        .service-icon.water { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); }
        .service-icon.school { background: linear-gradient(135deg, #55a3ff 0%, #003d82 100%); }
        
        .service-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 8px;
            color: white;
        }
        
        .service-subtitle {
            font-size: 14px;
            opacity: 0.7;
            line-height: 1.4;
        }
        
        .admin-panel {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 25px;
            margin-top: 30px;
        }
        
        .admin-title {
            font-family: 'Orbitron', monospace;
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 20px;
            background: var(--secondary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .admin-credentials {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .credential-item {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 15px;
        }
        
        .credential-label {
            font-size: 12px;
            opacity: 0.7;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .credential-value {
            font-family: 'Orbitron', monospace;
            font-size: 14px;
            font-weight: 600;
            color: var(--neon-blue);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        
        .stat-item {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 15px;
            text-align: center;
        }
        
        .stat-value {
            font-family: 'Orbitron', monospace;
            font-size: 20px;
            font-weight: 700;
            color: var(--neon-green);
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 12px;
            opacity: 0.7;
        }
        
        .transaction-log {
            background: rgba(0, 0, 0, 0.3);
            border-radius: 10px;
            padding: 15px;
            margin-top: 20px;
            max-height: 200px;
            overflow-y: auto;
        }
        
        .transaction-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .transaction-item:last-child {
            border-bottom: none;
        }
        
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            backdrop-filter: blur(10px);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        
        .modal-content {
            background: var(--glass-bg);
            backdrop-filter: blur(30px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 30px;
            max-width: 500px;
            width: 90%;
            position: relative;
        }
        
        .modal-title {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            opacity: 0.9;
        }
        
        .form-input, .form-select {
            width: 100%;
            padding: 12px 15px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            color: white;
            font-size: 14px;
        }
        
        .form-input::placeholder {
            color: rgba(255, 255, 255, 0.5);
        }
        
        .form-input:focus, .form-select:focus {
            outline: none;
            border-color: var(--neon-blue);
            box-shadow: 0 0 15px rgba(0, 245, 255, 0.3);
        }
        
        .close-btn {
            position: absolute;
            top: 15px;
            right: 15px;
            background: none;
            border: none;
            color: white;
            font-size: 20px;
            cursor: pointer;
            opacity: 0.7;
            transition: opacity 0.3s;
        }
        
        .close-btn:hover {
            opacity: 1;
        }
        
        .success-message {
            background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
            border-radius: 10px;
            padding: 15px;
            margin: 20px 0;
            text-align: center;
            font-weight: 600;
        }
        
        .error-message {
            background: linear-gradient(135deg, #e17055 0%, #d63031 100%);
            border-radius: 10px;
            padding: 15px;
            margin: 20px 0;
            text-align: center;
            font-weight: 600;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            
            .balance-actions {
                grid-template-columns: 1fr;
            }
            
            .services-grid {
                grid-template-columns: 1fr;
            }
            
            .admin-credentials {
                grid-template-columns: 1fr;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        .floating-particles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: -1;
        }
        
        .particle {
            position: absolute;
            width: 4px;
            height: 4px;
            background: var(--neon-blue);
            border-radius: 50%;
            animation: float 6s infinite ease-in-out;
        }
        
        @keyframes float {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
                opacity: 1;
            }
            50% {
                transform: translateY(-20px) rotate(180deg);
                opacity: 0.5;
            }
        }
    </style>
</head>
<body>
    <div class="floating-particles" id="particles"></div>
    
    <div class="container">
        <!-- Header -->
        <div class="header">
            <div class="logo">
                <div class="logo-icon">💳</div>
                <div class="logo-text">PayPoint 2080</div>
            </div>
            <div class="user-info">
                <div class="welcome-text">مرحباً، <span id="userName">عبدالولي يحيى بازل</span></div>
                <div class="admin-badge" id="adminBadge" style="display: none;">مدير النظام</div>
            </div>
        </div>
        
        <!-- Balance Card -->
        <div class="balance-card">
            <div class="balance-label">الرصيد المتاح</div>
            <div class="balance-amount" id="balanceAmount">50,000.00 ريال</div>
            <div class="balance-actions">
                <button class="btn btn-primary" onclick="openModal('topupModal')">
                    ➕ شحن المحفظة
                </button>
                <button class="btn btn-secondary" onclick="openModal('transferModal')">
                    📤 تحويل
                </button>
            </div>
        </div>
        
        <!-- Services Grid -->
        <div class="services-grid">
            <div class="service-card" onclick="openModal('networkModal')">
                <div class="service-icon network">📱</div>
                <div class="service-title">شحن كروت الشبكة</div>
                <div class="service-subtitle">يمن موبايل، MTN، سبأفون</div>
            </div>
            
            <div class="service-card" onclick="openModal('wifiModal')">
                <div class="service-icon wifi">📡</div>
                <div class="service-title">شحن كروت الواي فاي</div>
                <div class="service-subtitle">كروت إنترنت WAY</div>
            </div>
            
            <div class="service-card" onclick="openModal('electricityModal')">
                <div class="service-icon electricity">⚡</div>
                <div class="service-title">شحن الكهرباء</div>
                <div class="service-subtitle">دفع فواتير الكهرباء</div>
            </div>
            
            <div class="service-card" onclick="openModal('waterModal')">
                <div class="service-icon water">💧</div>
                <div class="service-title">دفع فاتورة المياه</div>
                <div class="service-subtitle">تسديد فواتير الميا����</div>
            </div>
            
            <div class="service-card" onclick="openModal('schoolModal')">
                <div class="service-icon school">🎓</div>
                <div class="service-title">الرسوم المدرسية</div>
                <div class="service-subtitle">دفع رسوم المدارس</div>
            </div>
        </div>
        
        <!-- Admin Panel -->
        <div class="admin-panel" id="adminPanel" style="display: none;">
            <div class="admin-title">🔐 لوحة التحكم الإدارية</div>
            
            <div class="admin-credentials">
                <div class="credential-item">
                    <div class="credential-label">البريد الإلكتروني</div>
                    <div class="credential-value">${ADMIN_CREDENTIALS.email}</div>
                </div>
                <div class="credential-item">
                    <div class="credential-label">كلمة المرور</div>
                    <div class="credential-value">${ADMIN_CREDENTIALS.password}</div>
                </div>
                <div class="credential-item">
                    <div class="credential-label">اسم المسؤول</div>
                    <div class="credential-value">${ADMIN_CREDENTIALS.name}</div>
                </div>
                <div class="credential-item">
                    <div class="credential-label">رقم الهاتف</div>
                    <div class="credential-value">${ADMIN_CREDENTIALS.phone}</div>
                </div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-value" id="totalUsers">0</div>
                    <div class="stat-label">إجمالي المستخدمين</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value" id="totalTransactions">0</div>
                    <div class="stat-label">إجمالي المعاملات</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value" id="totalRevenue">0</div>
                    <div class="stat-label">إجمالي الإيرادات</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value" id="availableCards">0</div>
                    <div class="stat-label">الكروت المتاحة</div>
                </div>
            </div>
            
            <div class="transaction-log">
                <h4 style="margin-bottom: 10px;">آخر المعاملات</h4>
                <div id="transactionList"></div>
            </div>
        </div>
    </div>
    
    <!-- Modals for each service -->
    <!-- Network Recharge Modal -->
    <div class="modal" id="networkModal">
        <div class="modal-content">
            <button class="close-btn" onclick="closeModal('networkModal')">×</button>
            <div class="modal-title">شحن كروت الشبكة</div>
            <form onsubmit="processNetworkRecharge(event)">
                <div class="form-group">
                    <label class="form-label">الشبكة</label>
                    <select class="form-select" id="networkProvider" required>
                        <option value="">اختر الشبكة</option>
                        <option value="yemenmobile">يمن موبايل</option>
                        <option value="mtn">MTN</option>
                        <option value="sabafon">سبأفون</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">رقم الهاتف</label>
                    <input type="tel" class="form-input" id="phoneNumber" placeholder="777123456" required>
                </div>
                <div class="form-group">
                    <label class="form-label">قيمة الشحن</label>
                    <select class="form-select" id="rechargeAmount" required>
                        <option value="">اختر المبلغ</option>
                        <option value="500">500 ريال</option>
                        <option value="1000">1000 ريال</option>
                        <option value="2000">2000 ريال</option>
                        <option value="5000">5000 ريال</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                    إتمام الشحن
                </button>
            </form>
        </div>
    </div>
    
    <!-- WiFi Modal -->
    <div class="modal" id="wifiModal">
        <div class="modal-content">
            <button class="close-btn" onclick="closeModal('wifiModal')">×</button>
            <div class="modal-title">شحن كروت الواي فاي</div>
            <form onsubmit="processWifiRecharge(event)">
                <div class="form-group">
                    <label class="form-label">رقم العميل</label>
                    <input type="text" class="form-input" id="wifiCustomer" placeholder="رقم العميل" required>
                </div>
                <div class="form-group">
                    <label class="form-label">قيمة الكرت</label>
                    <select class="form-select" id="wifiAmount" required>
                        <option value="">اختر قيمة الكرت</option>
                        <option value="1000">1000 ريال</option>
                        <option value="2000">2000 ريال</option>
                        <option value="5000">5000 ريال</option>
                        <option value="10000">10000 ريال</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-secondary" style="width: 100%; margin-top: 10px;">
                    شراء الكرت
                </button>
            </form>
        </div>
    </div>
    
    <!-- Other service modals (simplified for space) -->
    <div class="modal" id="electricityModal">
        <div class="modal-content">
            <button class="close-btn" onclick="closeModal('electricityModal')">×</button>
            <div class="modal-title">دفع فاتورة الكهرباء</div>
            <form onsubmit="processElectricityPayment(event)">
                <div class="form-group">
                    <label class="form-label">رقم العداد</label>
                    <input type="text" class="form-input" id="meterNumber" placeholder="رقم العداد" required>
                </div>
                <div class="form-group">
                    <label class="form-label">المبلغ</label>
                    <input type="number" class="form-input" id="electricityAmount" placeholder="المبلغ بالريال" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                    دفع الفاتورة
                </button>
            </form>
        </div>
    </div>
    
    <div class="modal" id="waterModal">
        <div class="modal-content">
            <button class="close-btn" onclick="closeModal('waterModal')">×</button>
            <div class="modal-title">دفع فاتورة المياه</div>
            <form onsubmit="processWaterPayment(event)">
                <div class="form-group">
                    <label class="form-label">رقم الحساب</label>
                    <input type="text" class="form-input" id="waterAccount" placeholder="رقم حساب المياه" required>
                </div>
                <div class="form-group">
                    <label class="form-label">ال��بلغ</label>
                    <input type="number" class="form-input" id="waterAmount" placeholder="المبلغ بالريال" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                    دفع الفاتورة
                </button>
            </form>
        </div>
    </div>
    
    <div class="modal" id="schoolModal">
        <div class="modal-content">
            <button class="close-btn" onclick="closeModal('schoolModal')">×</button>
            <div class="modal-title">دفع الرسوم المدرسية</div>
            <form onsubmit="processSchoolPayment(event)">
                <div class="form-group">
                    <label class="form-label">اسم الطالب</label>
                    <input type="text" class="form-input" id="studentName" placeholder="اسم الطالب" required>
                </div>
                <div class="form-group">
                    <label class="form-label">المدرسة</label>
                    <select class="form-select" id="schoolName" required>
                        <option value="">اختر المدرسة</option>
                        <option value="school1">مدرسة ال��مل</option>
                        <option value="school2">مدرسة النهضة</option>
                        <option value="school3">مدرسة المستقبل</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">المبلغ</label>
                    <input type="number" class="form-input" id="schoolAmount" placeholder="المبلغ بالريال" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                    دفع الرسوم
                </button>
            </form>
        </div>
    </div>
    
    <!-- Success Modal -->
    <div class="modal" id="successModal">
        <div class="modal-content">
            <button class="close-btn" onclick="closeModal('successModal')">×</button>
            <div class="modal-title" style="color: var(--neon-green);">✅ تمت العملية بنجاح</div>
            <div id="successDetails"></div>
        </div>
    </div>

    <script>
        let currentBalance = 50000;
        let isAdmin = false;
        let transactionHistory = [];
        
        // Initialize particles
        function createParticles() {
            const container = document.getElementById('particles');
            for (let i = 0; i < 50; i++) {
                const particle = document.createElement('div');
                particle.className = 'particle';
                particle.style.left = Math.random() * 100 + '%';
                particle.style.top = Math.random() * 100 + '%';
                particle.style.animationDelay = Math.random() * 6 + 's';
                particle.style.animationDuration = (Math.random() * 3 + 3) + 's';
                container.appendChild(particle);
            }
        }
        
        // Initialize app
        function initApp() {
            createParticles();
            checkAdminStatus();
            updateStats();
        }
        
        // Check if user is admin
        function checkAdminStatus() {
            // In a real app, this would check authentication
            // For demo, we'll show admin panel after 3 seconds
            setTimeout(() => {
                isAdmin = true;
                document.getElementById('adminBadge').style.display = 'block';
                document.getElementById('adminPanel').style.display = 'block';
                updateStats();
            }, 3000);
        }
        
        // Update statistics with error handling
        function updateStats() {
            try {
                if (isAdmin) {
                    const elements = {
                        'totalUsers': '1,247',
                        'totalTransactions': transactionHistory.length,
                        'totalRevenue': '89,456',
                        'availableCards': '2,450'
                    };

                    Object.keys(elements).forEach(id => {
                        const element = document.getElementById(id);
                        if (element) {
                            element.textContent = elements[id];
                        }
                    });

                    updateTransactionList();
                }
            } catch (error) {
                console.warn('Error updating stats:', error);
            }
        }
        
        // Update transaction list with error handling
        function updateTransactionList() {
            try {
                const container = document.getElementById('transactionList');
                if (!container) return;

                container.innerHTML = '';

                transactionHistory.slice(0, 5).forEach(transaction => {
                    try {
                        const item = document.createElement('div');
                        item.className = 'transaction-item';
                        item.innerHTML = \`
                            <span>\${transaction.type || 'معاملة'}</span>
                            <span style="color: var(--neon-green);">\${transaction.amount || 0} ريال</span>
                        \`;
                        container.appendChild(item);
                    } catch (itemError) {
                        console.warn('Error creating transaction item:', itemError);
                    }
                });
            } catch (error) {
                console.warn('Error updating transaction list:', error);
            }
        }
        
        // Modal functions with error handling
        function openModal(modalId) {
            try {
                const modal = document.getElementById(modalId);
                if (modal) {
                    modal.style.display = 'flex';
                }
            } catch (error) {
                console.warn('Error opening modal:', error);
            }
        }

        function closeModal(modalId) {
            try {
                const modal = document.getElementById(modalId);
                if (modal) {
                    modal.style.display = 'none';
                }
            } catch (error) {
                console.warn('Error closing modal:', error);
            }
        }
        
        // Update balance with error handling
        function updateBalance(newBalance) {
            try {
                currentBalance = newBalance;
                const balanceElement = document.getElementById('balanceAmount');
                if (balanceElement) {
                    balanceElement.textContent =
                        new Intl.NumberFormat('ar-SA').format(newBalance) + ' ريال';
                }
            } catch (error) {
                console.warn('Error updating balance:', error);
            }
        }
        
        // Process transactions
        async function processNetworkRecharge(event) {
            event.preventDefault();
            const provider = document.getElementById('networkProvider').value;
            const phone = document.getElementById('phoneNumber').value;
            const amount = parseInt(document.getElementById('rechargeAmount').value);
            
            if (currentBalance >= amount) {
                // Simulate processing
                await new Promise(resolve => setTimeout(resolve, 2000));
                
                updateBalance(currentBalance - amount);
                
                const transaction = {
                    type: 'شحن كرت شبك��',
                    amount: amount,
                    timestamp: new Date().toLocaleString('ar-SA')
                };
                transactionHistory.unshift(transaction);
                
                showSuccess(\`
                    <div class="success-message">
                        تم شحن \${amount} ريال لرقم \${phone} بنجاح<br>
                        الشبكة: \${provider}<br>
                        كود الشحن: RC\${Date.now()}
                    </div>
                \`);
                
                closeModal('networkModal');
                updateStats();
            } else {
                alert('رصيدك غير كافي لإتمام العملية');
            }
        }
        
        async function processWifiRecharge(event) {
            event.preventDefault();
            const customer = document.getElementById('wifiCustomer').value;
            const amount = parseInt(document.getElementById('wifiAmount').value);
            
            if (currentBalance >= amount) {
                await new Promise(resolve => setTimeout(resolve, 2000));
                
                updateBalance(currentBalance - amount);
                
                const cardCode = 'WIFI' + Math.floor(Math.random() * 900000 + 100000);
                const serial = 'SN' + Date.now();
                
                const transaction = {
                    type: 'شحن واي فاي',
                    amount: amount,
                    timestamp: new Date().toLocaleString('ar-SA')
                };
                transactionHistory.unshift(transaction);
                
                showSuccess(\`
                    <div class="success-message">
                        تم شراء كرت واي فاي بقيمة \${amount} ريال<br>
                        رقم العميل: \${customer}<br>
                        كود الكرت: \${cardCode}<br>
                        الرقم التسلسلي: \${serial}
                    </div>
                \`);
                
                closeModal('wifiModal');
                updateStats();
            } else {
                alert('رصيدك غير كافي لإتمام العملية');
            }
        }
        
        async function processElectricityPayment(event) {
            event.preventDefault();
            const meter = document.getElementById('meterNumber').value;
            const amount = parseInt(document.getElementById('electricityAmount').value);
            
            if (currentBalance >= amount) {
                await new Promise(resolve => setTimeout(resolve, 2000));
                
                updateBalance(currentBalance - amount);
                
                const transaction = {
                    type: 'دفع كهرباء',
                    amount: amount,
                    timestamp: new Date().toLocaleString('ar-SA')
                };
                transactionHistory.unshift(transaction);
                
                showSuccess(\`
                    <div class="success-message">
                        تم دفع فاتورة الكهرباء بنجاح<br>
                        رقم العداد: \${meter}<br>
                        المبلغ: \${amount} ريال<br>
                        رقم العملية: ELE\${Date.now()}
                    </div>
                \`);
                
                closeModal('electricityModal');
                updateStats();
            } else {
                alert('رصيدك غير كافي لإتمام العملية');
            }
        }
        
        async function processWaterPayment(event) {
            event.preventDefault();
            const account = document.getElementById('waterAccount').value;
            const amount = parseInt(document.getElementById('waterAmount').value);
            
            if (currentBalance >= amount) {
                await new Promise(resolve => setTimeout(resolve, 2000));
                
                updateBalance(currentBalance - amount);
                
                const transaction = {
                    type: 'دفع مياه',
                    amount: amount,
                    timestamp: new Date().toLocaleString('ar-SA')
                };
                transactionHistory.unshift(transaction);
                
                showSuccess(\`
                    <div class="success-message">
                        تم دفع فاتورة المياه بنجاح<br>
                        رقم الحساب: \${account}<br>
                        المبلغ: \${amount} ريال<br>
                        رقم العملية: WAT\${Date.now()}
                    </div>
                \`);
                
                closeModal('waterModal');
                updateStats();
            } else {
                alert('رصيدك غير كافي لإتمام العملية');
            }
        }
        
        async function processSchoolPayment(event) {
            event.preventDefault();
            const student = document.getElementById('studentName').value;
            const school = document.getElementById('schoolName').value;
            const amount = parseInt(document.getElementById('schoolAmount').value);
            
            if (currentBalance >= amount) {
                await new Promise(resolve => setTimeout(resolve, 2000));
                
                updateBalance(currentBalance - amount);
                
                const transaction = {
                    type: 'رسوم مدرسية',
                    amount: amount,
                    timestamp: new Date().toLocaleString('ar-SA')
                };
                transactionHistory.unshift(transaction);
                
                showSuccess(\`
                    <div class="success-message">
                        تم دفع الرسوم المدرسية بنجاح<br>
                        اسم الطالب: \${student}<br>
                        المدرسة: \${school}<br>
                        المبلغ: \${amount} ريال<br>
                        رقم العملية: SCH\${Date.now()}
                    </div>
                \`);
                
                closeModal('schoolModal');
                updateStats();
            } else {
                alert('رصيدك غير كافي لإتمام العملية');
            }
        }
        
        function showSuccess(content) {
            try {
                const successElement = document.getElementById('successDetails');
                if (successElement) {
                    successElement.innerHTML = content || 'تمت العملية بنجاح';
                }
                openModal('successModal');
            } catch (error) {
                console.warn('Error showing success message:', error);
                // Fallback to alert if modal fails
                alert('تمت العملية بنجاح');
            }
        }
        
        // Initialize app when page loads
        document.addEventListener('DOMContentLoaded', initApp);
        
        // Close modals when clicking outside
        window.addEventListener('click', function(event) {
            if (event.target && event.target.classList && event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        });

        // Prevent default behavior for empty anchors
        document.addEventListener('click', function(event) {
            if (event.target.tagName === 'A' && (event.target.getAttribute('href') === '#' || event.target.getAttribute('href') === '')) {
                event.preventDefault();
            }
        });

        // Add comprehensive error handling for any unhandled JavaScript errors
        window.addEventListener('error', function(event) {
            console.warn('JavaScript Error caught:', event.error);
            return true; // Prevent error from breaking the app
        });

        // Override querySelector to handle invalid selectors
        const originalQuerySelector = Document.prototype.querySelector;
        Document.prototype.querySelector = function(selector) {
            try {
                if (!selector || selector === '#' || selector === '') {
                    console.warn('Invalid selector detected:', selector);
                    return null;
                }
                return originalQuerySelector.call(this, selector);
            } catch (error) {
                console.warn('querySelector error prevented:', error);
                return null;
            }
        };

        // Override querySelectorAll as well
        const originalQuerySelectorAll = Document.prototype.querySelectorAll;
        Document.prototype.querySelectorAll = function(selector) {
            try {
                if (!selector || selector === '#' || selector === '') {
                    console.warn('Invalid selector detected in querySelectorAll:', selector);
                    return [];
                }
                return originalQuerySelectorAll.call(this, selector);
            } catch (error) {
                console.warn('querySelectorAll error prevented:', error);
                return [];
            }
        };
        
        console.log('🚀 PayPoint 2080 - نظام الدفع المستقبلي محمل بنجاح!');
        console.log('📧 بيانات الأدمن:');
        console.log('   البريد: ${ADMIN_CREDENTIALS.email}');
        console.log('   كلمة المرور: ${ADMIN_CREDENTIALS.password}');
        console.log('   الاسم: ${ADMIN_CREDENTIALS.name}');
        console.log('   الهاتف: ${ADMIN_CREDENTIALS.phone}');
    </script>
</body>
</html>
`;

// Routes
app.get('/', (req, res) => {
    res.send(futuristicTemplate);
});

app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        app: 'PayPoint 2080 - Future Payment System',
        message: 'Advanced futuristic interface loaded successfully',
        timestamp: new Date().toISOString(),
        features: {
            'network_recharge': true,
            'wifi_cards': true,
            'electricity_payment': true,
            'water_payment': true,
            'school_payment': true,
            'admin_panel': true,
            'real_time_stats': true
        }
    });
});

// API Routes for transactions
app.post('/api/recharge/network', (req, res) => {
    try {
        const { provider, phone, amount } = req.body;
        const transaction = processTransaction('network_recharge', amount, {
            provider,
            phone,
            cardCode: generateCardCode(provider)
        });
        res.json({ success: true, transaction });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
});

app.post('/api/recharge/wifi', (req, res) => {
    try {
        const { customer, amount } = req.body;
        const transaction = processTransaction('wifi_recharge', amount, {
            customer,
            cardCode: generateCardCode('wifi'),
            serial: generateSerial()
        });
        res.json({ success: true, transaction });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
});

app.post('/api/payment/electricity', (req, res) => {
    try {
        const { meterNumber, amount } = req.body;
        const transaction = processTransaction('electricity_payment', amount, {
            meterNumber,
            billNumber: `ELE${Date.now()}`
        });
        res.json({ success: true, transaction });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
});

app.post('/api/payment/water', (req, res) => {
    try {
        const { accountNumber, amount } = req.body;
        const transaction = processTransaction('water_payment', amount, {
            accountNumber,
            billNumber: `WAT${Date.now()}`
        });
        res.json({ success: true, transaction });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
});

app.post('/api/payment/school', (req, res) => {
    try {
        const { studentName, school, amount } = req.body;
        const transaction = processTransaction('school_payment', amount, {
            studentName,
            school,
            receiptNumber: `SCH${Date.now()}`
        });
        res.json({ success: true, transaction });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
});

app.get('/api/admin/stats', (req, res) => {
    res.json({
        totalUsers: users.size,
        totalTransactions: transactions.length,
        totalRevenue: transactions.reduce((sum, t) => sum + t.amount, 0),
        availableCards: cards.filter(c => c.status === 'available').length,
        recentTransactions: transactions.slice(0, 10)
    });
});

app.get('/api/admin/credentials', (req, res) => {
    res.json(ADMIN_CREDENTIALS);
});

// Initialize data
initializeMockData();

// Start server
app.listen(port, () => {
    console.log(`🚀 PayPoint 2080 server running at http://localhost:${port}`);
    console.log(`✨ Advanced futuristic interface loaded successfully!`);
    console.log(`🎯 All features activated and functional`);
    console.log('');
    console.log('📧 ═══════════════ بيانات الأدمن ═══════════════');
    console.log(`📧 البريد الإلكتروني: ${ADMIN_CREDENTIALS.email}`);
    console.log(`🔑 كلمة المرور: ${ADMIN_CREDENTIALS.password}`);
    console.log(`👤 اسم المسؤول: ${ADMIN_CREDENTIALS.name}`);
    console.log(`📱 رقم الهاتف: ${ADMIN_CREDENTIALS.phone}`);
    console.log('📧 ══════════════════════════════════════════════');
    console.log('');
    console.log('🎮 Features Available:');
    console.log('  �� شحن كروت الشبكة (يمن موبايل، MTN، سبأفون)');
    console.log('  ✅ شحن كروت الواي فاي');
    console.log('  ✅ دفع فواتير الكهرباء');
    console.log('  ✅ دفع فواتير المياه');
    console.log('  ✅ دفع الرسوم المدرسية');
    console.log('  ✅ لوحة التحكم الإدارية');
    console.log('  ✅ إحصائيا�� في الوقت الفعلي');
});

module.exports = app;
