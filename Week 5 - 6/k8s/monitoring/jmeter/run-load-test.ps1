# PowerShell script để chạy JMeter Load Test
# File: run-load-test.ps1

param(
    [string]$JMeterPath = "jmeter",
    [string]$TestPlan = "cpu-load-test.jmx",
    [string]$ResultsDir = "results",
    [int]$Duration = 300,
    [int]$Threads = 50
)

Write-Host "🚀 Starting CPU Load Test với JMeter..." -ForegroundColor Green

# Tạo thư mục results nếu chưa có
if (!(Test-Path $ResultsDir)) {
    New-Item -ItemType Directory -Path $ResultsDir
    Write-Host "✅ Đã tạo thư mục $ResultsDir" -ForegroundColor Yellow
}

# Kiểm tra JMeter có sẵn không
try {
    & $JMeterPath -v | Out-Null
    Write-Host "✅ JMeter đã sẵn sàng" -ForegroundColor Green
} catch {
    Write-Host "❌ Không tìm thấy JMeter. Vui lòng cài đặt và thêm vào PATH." -ForegroundColor Red
    Write-Host "Download từ: https://jmeter.apache.org/download_jmeter.cgi" -ForegroundColor Yellow
    exit 1
}

# Kiểm tra service có sẵn không
try {
    $response = Invoke-WebRequest -Uri "http://localhost:30080" -TimeoutSec 5
    Write-Host "✅ Course Tracker service đang chạy" -ForegroundColor Green
} catch {
    Write-Host "❌ Không thể kết nối đến service http://localhost:30080" -ForegroundColor Red
    Write-Host "Vui lòng đảm bảo service đang chạy: kubectl get svc -n default" -ForegroundColor Yellow
    exit 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$resultsFile = Join-Path $ResultsDir "load-test-$timestamp.jtl"
$htmlReport = Join-Path $ResultsDir "html-report-$timestamp"

Write-Host "📊 Thông số test:" -ForegroundColor Cyan
Write-Host "   - Threads: $Threads" -ForegroundColor White
Write-Host "   - Duration: $Duration seconds" -ForegroundColor White  
Write-Host "   - Results: $resultsFile" -ForegroundColor White
Write-Host "   - HTML Report: $htmlReport" -ForegroundColor White

Write-Host "`n🎯 Bắt đầu load test..." -ForegroundColor Yellow
Write-Host "Theo dõi CPU usage: kubectl top pods -n default" -ForegroundColor Gray
Write-Host "Theo dõi alerts: http://localhost:30093 (nếu AlertManager đã deploy)" -ForegroundColor Gray

# Chạy JMeter
$jmeterArgs = @(
    "-n",                    # Non-GUI mode
    "-t", $TestPlan,        # Test plan file
    "-l", $resultsFile,     # Results file  
    "-e",                   # Generate HTML report
    "-o", $htmlReport,      # HTML report output directory
    "-J", "SERVER_URL=localhost",
    "-J", "SERVER_PORT=30080",
    "-J", "threads=$Threads",
    "-J", "duration=$Duration"
)

Write-Host "`nĐang chạy: $JMeterPath $($jmeterArgs -join ' ')" -ForegroundColor Gray

try {
    & $JMeterPath $jmeterArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n🎉 Load test hoàn thành thành công!" -ForegroundColor Green
        Write-Host "📁 Kết quả: $resultsFile" -ForegroundColor Yellow
        Write-Host "📊 HTML Report: $htmlReport\index.html" -ForegroundColor Yellow
        
        # Mở HTML report nếu có thể
        $htmlFile = Join-Path $htmlReport "index.html"
        if (Test-Path $htmlFile) {
            Write-Host "`n🌐 Mở HTML report..." -ForegroundColor Green
            Start-Process $htmlFile
        }
        
        Write-Host "`n💡 Kiểm tra alerts:" -ForegroundColor Cyan
        Write-Host "   kubectl top pods -n default" -ForegroundColor White
        Write-Host "   curl http://localhost:30093/api/v1/alerts" -ForegroundColor White
        
    } else {
        Write-Host "`n❌ Load test thất bại với exit code: $LASTEXITCODE" -ForegroundColor Red
    }
    
} catch {
    Write-Host "`n❌ Lỗi khi chạy JMeter: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Script hoàn thành." -ForegroundColor Green