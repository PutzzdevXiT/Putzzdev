--[[
    Script: Tebak Yuk! 1v1 Clue Solver
    Fungsi: Membantu pemain menebak kata rahasia di game Tebak Yuk!
    Fitur: Prediksi kata berdasarkan jawaban "IYA/TIDAK/MUNGKIN" lawan
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Buat GUI Sederhana
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TebakYukSolver"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Buat biar bisa di-drag
local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(mainFrame)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Tebak Yuk! 1v1 Solver"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Tombol Mode Prediksi
local predictBtn = Instance.new("TextButton")
predictBtn.Size = UDim2.new(0.9, 0, 0, 30)
predictBtn.Position = UDim2.new(0.05, 0, 0, 40)
predictBtn.Text = "Mulai Prediksi Kata"
predictBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
predictBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
predictBtn.Parent = mainFrame

-- Tombol Reset
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.4, 0, 0, 30)
resetBtn.Position = UDim2.new(0.05, 0, 0, 80)
resetBtn.Text = "Reset"
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Parent = mainFrame

-- Display Hasil Prediksi
local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(0.9, 0, 0, 50)
resultLabel.Position = UDim2.new(0.05, 0, 0, 120)
resultLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resultLabel.Text = "Kata Prediksi: -\nTekan 'Mulai Prediksi'"
resultLabel.TextWrapped = true
resultLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
resultLabel.Parent = mainFrame

-- Variabel database kata (contoh)
local kataDatabase = {
    "apel", "mangga", "pisang", "jeruk", "semangka", "nanas", "anggur", "pepaya",
    "kucing", "anjing", "burung", "ikan", "ular", "harimau", "gajah", "singa",
    "merah", "biru", "kuning", "hijau", "hitam", "putih", "jingga", "ungu",
    "sepeda", "motor", "mobil", "pesawat", "kereta", "kapal", "bus", "truk"
}

-- Logika Prediksi
local possibleWords = {}
local predicting = false

local function resetPrediction()
    possibleWords = {}
    for _, word in ipairs(kataDatabase) do
        possibleWords[word] = true
    end
    resultLabel.Text = "Kata Prediksi: Semua kemungkinan\nKetik pertanyaan di chat..."
end

local function filterWordsByQuestion(question, answerType)
    -- answerType: "iya", "tidak", "mungkin"
    -- Ini simulasi sederhana, makin banyak data makin akurat
    local newPossible = {}
    for word in pairs(possibleWords) do
        -- Logika sederhana: cek apakah kata mengandung huruf dari pertanyaan
        -- Ini perlu dikembangkan dengan AI atau database yang lebih besar
        if answerType == "iya" then
            -- Anggap jawaban "iya" berarti kata terkait dengan pertanyaan
            if string.find(word, string.sub(question, 1, 2)) then
                newPossible[word] = true
            end
        elseif answerType == "tidak" then
            if not string.find(word, string.sub(question, 1, 2)) then
                newPossible[word] = true
            end
        else -- "mungkin"
            newPossible[word] = true
        end
    end
    possibleWords = newPossible
end

local function updatePredictionDisplay()
    local words = {}
    for word in pairs(possibleWords) do
        table.insert(words, word)
    end
    if #words == 0 then
        resultLabel.Text = "Kata Prediksi: (Tidak ada kata yang cocok)\nTekan Reset"
    elseif #words <= 5 then
        resultLabel.Text = "Kata Prediksi: " .. table.concat(words, ", ") .. "\n" .. #words .. " kemungkinan tersisa"
    else
        resultLabel.Text = "Kata Prediksi: " .. words[1] .. ", " .. words[2] .. ", ...\n" .. #words .. " kemungkinan tersisa"
    end
end

-- Mendeteksi chat pemain lain (pemberi clue)
local function onChatted(speaker, message)
    if not predicting then return end
    if speaker == player then return end -- Abaikan chat sendiri
    
    local lowerMsg = string.lower(message)
    
    -- Deteksi jawaban "iya", "tidak", "mungkin"
    local answerType = nil
    if string.find(lowerMsg, "iya") or string.find(lowerMsg, "ya") then
        answerType = "iya"
    elseif string.find(lowerMsg, "tidak") or string.find(lowerMsg, "bukan") then
        answerType = "tidak"
    elseif string.find(lowerMsg, "mungkin") or string.find(lowerMsg, "bisa jadi") then
        answerType = "mungkin"
    end
    
    if answerType then
        -- Ambil pertanyaan terakhir dari chat (sederhana, bisa dikembangkan)
        -- Untuk demo, kita asumsikan pertanyaan adalah teks sebelum jawaban
        -- Script ini perlu dikembangkan lebih lanjut untuk capture pertanyaan dengan akurat
        local question = "pertanyaan" -- Ganti dengan logika capture pertanyaan
        filterWordsByQuestion(question, answerType)
        updatePredictionDisplay()
    end
end

-- Pasang listener chat
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(msg)
        onChatted(p, msg)
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(msg)
        onChatted(p, msg)
    end)
end

-- Tombol aksi
predictBtn.MouseButton1Click:Connect(function()
    predicting = true
    resetPrediction()
    predictBtn.Text = "Sedang Memprediksi..."
    predictBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    resultLabel.Text = "Kata Prediksi: Memulai...\nTanyakan sesuatu ke lawan!"
end)

resetBtn.MouseButton1Click:Connect(function()
    resetPrediction()
    updatePredictionDisplay()
end)

-- Pesan awal
print("Script Tebak Yuk! 1v1 Solver siap digunakan.")
print("Tekan 'Mulai Prediksi' lalu tanyakan pertanyaan ke lawan main.")