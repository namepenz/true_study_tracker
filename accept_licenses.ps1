$env:JAVA_HOME="C:\Program Files\Unity\Hub\Editor\6000.3.5f2\Editor\Data\PlaybackEngines\AndroidPlayer\OpenJDK"
1..20 | ForEach-Object { "y" } | & "..\flutter\bin\flutter.bat" doctor --android-licenses
