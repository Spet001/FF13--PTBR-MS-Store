# Script para adicionar ou remover opções de "Abrir PowerShell como Administrador"
# no menu de contexto do Explorador de Arquivos do Windows.

function Add-PowerShellContextMenu {
    Write-Host "Adicionando 'Abrir PowerShell como Administrador' ao menu de contexto..." -ForegroundColor Yellow
    # Adiciona a entrada para o menu de contexto de pastas
    $regPathFolder = "HKCU:\Software\Classes\Directory\shell\PowerShellAdmin"
    New-Item -Path $regPathFolder -Force | Out-Null
    Set-ItemProperty -Path $regPathFolder -Name "(Default)" -Value "Abrir PowerShell como Administrador" -Force
    Set-ItemProperty -Path $regPathFolder -Name "Icon" -Value "powershell.exe" -Force

    $regPathCommandFolder = "HKCU:\Software\Classes\Directory\shell\PowerShellAdmin\command"
    New-Item -Path $regPathCommandFolder -Force | Out-Null
    Set-ItemProperty -Path $regPathCommandFolder -Name "(Default)" -Value "powershell.exe -NoExit -Command Set-Location '%V' -Verb RunAs" -Force

    # Adiciona a entrada para o menu de contexto de fundo de pastas (quando clica com direito em espaço vazio)
    $regPathBackground = "HKCU:\Software\Classes\Directory\Background\shell\PowerShellAdmin"
    New-Item -Path $regPathBackground -Force | Out-Null
    Set-ItemProperty -Path $regPathBackground -Name "(Default)" -Value "Abrir PowerShell aqui como Administrador" -Force
    Set-ItemProperty -Path $regPathBackground -Name "Icon" -Value "powershell.exe" -Force

    $regPathCommandBackground = "HKCU:\Software\Classes\Directory\Background\shell\PowerShellAdmin\command"
    New-Item -Path $regPathCommandBackground -Force | Out-Null
    Set-ItemProperty -Path $regPathCommandBackground -Name "(Default)" -Value "powershell.exe -NoExit -Command Set-Location '%V' -Verb RunAs" -Force

    Write-Host "Opções adicionadas com sucesso ao menu de contexto!" -ForegroundColor Green
}

function Remove-PowerShellContextMenu {
    Write-Host "Removendo 'Abrir PowerShell como Administrador' do menu de contexto..." -ForegroundColor Yellow
    # Remove a entrada de pastas
    Remove-Item -Path "HKCU:\Software\Classes\Directory\shell\PowerShellAdmin" -Recurse -ErrorAction SilentlyContinue
    # Remove a entrada de fundo de pastas
    Remove-Item -Path "HKCU:\Software\Classes\Directory\Background\shell\PowerShellAdmin" -Recurse -ErrorAction SilentlyContinue

    Write-Host "Opções removidas com sucesso do menu de contexto!" -ForegroundColor Green
}

Write-Host "--- Gerenciador de Menu de Contexto do PowerShell ---" -ForegroundColor Blue
Write-Host "1. Adicionar opções 'Abrir PowerShell como Administrador'"
Write-Host "2. Remover opções 'Abrir PowerShell como Administrador'"
Write-Host "3. Sair"

$choice = Read-Host "Digite sua escolha (1, 2 ou 3)"

switch ($choice) {
    "1" { Add-PowerShellContextMenu }
    "2" { Remove-PowerShellContextMenu }
    "3" { Write-Host "Saindo..." }
    default { Write-Host "Escolha inválida. Saindo..." -ForegroundColor Red }
}

Read-Host "Pressione Enter para continuar..."