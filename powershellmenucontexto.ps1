#pragma script_options(language_version=5.0, suppress_warning=false, default_language=en-US)

# Este script garante que a associa��o de arquivos .ps1 esteja correta
# e adiciona op��es de execu��o ao menu de contexto.
# Ele precisa ser executado apenas uma vez.

#region Verifica��o de Privil�gios de Administrador
# Verificando se o script est� sendo executado como administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERRO] Este script precisa ser executado com privil�gios de administrador." -ForegroundColor Red
    Write-Host "Por favor, clique com o bot�o direito no arquivo e selecione 'Executar como administrador'."
    Read-Host "Pressione Enter para sair..." | Out-Null
    exit
}
#endregion Verifica��o de Privil�gios de Administrador

Write-Host "Iniciando a verifica��o e modifica��o do Registro..."

try {
    # Define o caminho para a chave do Registro para a extens�o .ps1
    $extPath = "Registry::HKEY_CLASSES_ROOT\.ps1"
    
    # 1. Corrige a associa��o de arquivo para .ps1
    # Define o valor padr�o da chave .ps1 para 'Microsoft.PowerShellScript.1'
    Write-Host "Corrigindo a associa��o do tipo de arquivo .ps1..."
    Set-ItemProperty -Path $extPath -Name "(default)" -Value "Microsoft.PowerShellScript.1" -Force | Out-Null
    
    # Define os caminhos das chaves para as op��es de menu de contexto
    $shellPath = "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell"
    $runAsPath = "$shellPath\RunAs"
    $runPath = "$shellPath\Run"
    
    # 2. Adiciona a op��o "Executar com PowerShell como administrador"
    Write-Host "Adicionando a op��o 'Executar com PowerShell como administrador'..."
    New-Item -Path $runAsPath -Force | Out-Null
    Set-ItemProperty -Path $runAsPath -Name "(default)" -Value "Executar com PowerShell como administrador" -Force | Out-Null
    New-Item -Path "$runAsPath\Command" -Force | Out-Null
    Set-ItemProperty -Path "$runAsPath\Command" -Name "(default)" -Value "powershell.exe -ExecutionPolicy Bypass -NoExit -Command `"Set-Location -Path '%V'; & '%1'`"" -Force | Out-Null

    # 3. Adiciona a op��o "Executar com PowerShell"
    Write-Host "Adicionando a op��o 'Executar com PowerShell'..."
    New-Item -Path $runPath -Force | Out-Null
    Set-ItemProperty -Path $runPath -Name "(default)" -Value "Executar com PowerShell" -Force | Out-Null
    New-Item -Path "$runPath\Command" -Force | Out-Null
    Set-ItemProperty -Path "$runPath\Command" -Name "(default)" -Value "powershell.exe -NoExit -Command `"Set-Location -Path '%V'; & '%1'`"" -Force | Out-Null
    
    Write-Host ""
    Write-Host "[SUCESSO] As op��es de menu de contexto foram adicionadas!" -ForegroundColor Green
    Write-Host "Pode ser necess�rio reiniciar o Explorador de Arquivos ou o computador para que as altera��es apare�am."
}
catch {
    Write-Host ""
    Write-Host "[ERRO CR�TICO] Falha ao modificar o Registro." -ForegroundColor Red
    Write-Host "Mensagem de erro: $($_.Exception.Message)"
}

Write-Host ""
Read-Host "Pressione Enter para sair..." | Out-Null
