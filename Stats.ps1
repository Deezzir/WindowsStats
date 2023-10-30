# Define Tokens & Constants
$token = "your_token"
$chat_id = "chat_id"
$cost_per_hour = 35.226
$start_time = Get-Date -Year 2023 -Month 10 -Day 27 -Hour 0 -Minute 0 -Second 0

# Get CPU Utilization
$cpu_utilization = (Get-CimInstance -ClassName win32_processor | Measure-Object -Property LoadPercentage -Average).Average

# Get RAM Utilization
$ram_utilization = 100 - ((Get-WmiObject win32_operatingsystem).FreePhysicalMemory / (Get-WmiObject win32_operatingsystem).TotalVisibleMemorySize) * 100
$mb_used =  ((Get-WmiObject win32_operatingsystem).TotalVisibleMemorySize - (Get-WmiObject win32_operatingsystem).FreePhysicalMemory) / 1024
$gb_used = $mb_used / 1024
$gb_total = (Get-WmiObject win32_operatingsystem).TotalVisibleMemorySize / 1024 / 1024

#Get Cost & Uptime
$cur_time = Get-Date
$time_dt = $cur_time - $start_time
$uptime = $time_dt.TotalHours
$cost = $uptime * $cost_per_hour * 1.13

# Get the process using the Most RAM
$process = Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 1
$process_name = $process.ProcessName
$process_id = $process.Id

# Construct the message
$message = @"
CPU Utilization: $($cpu_utilization.ToString("F2"))%
RAM Utilization: $($ram_utilization.ToString("F3"))%
RAM used: $($mb_used.ToString("F0")) MB ($($gb_used.ToString("F0")) / $($gb_total.ToString("F0")) GB)
Uptime: $($uptime.ToString("F1")) hours
Cost: ~$($cost.ToString("F2"))$ USD

Process using the most RAM: '$($process_name)' (ID: $($process_id))
"@

# Send the message to the Telegram bot
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" -Method Post -Body @{
    chat_id = $chat_id
    text = $message
}
