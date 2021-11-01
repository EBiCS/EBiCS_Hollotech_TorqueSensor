
'Wireless torque sensor at crank of Chainwheel
$regfile = "attiny85.dat"
$crystal = 8000000
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space



'Timer0 f�r PWM initialisieren



Config Timer0 = Pwm , Pwm = On , Prescale = 1 , Compare A Pwm = Clear up , Compare B Pwm = Clear up

Enable Timer0
Start Timer0
On Ovf0 Tick
Ocr0a = 127

'Timer1 f�r das Ausz�hlen des OP-Signals initialisieren


Config Timer1 = Timer , Prescale = 8 , Clear Timer = 0 , Compare A = Disconnect

Enable Timer1

Start Timer1
On Ovf1 Tim1Ovf

'Ein- und Ausg�nge initialisieren




Config Portb.0 = Output                                     'PWM Ausgang f�r analogen Ausgang Torquesignal
Config Portb.2 = Input                                      'PB2 f�r Einlesen Pulsfolge von OP �ber externen Interrupt
Config Portb.3 = Output                                     'PB3 Ausgang zum Debuggen
Config Portb.4 = Output                                     'PB4 Ausgang f�r PAS Signal

On Int0 ExtInterrupt                                             'externen Interrupt auf PB2 (INT0) einstellen und aktivieren
Config Int0 = Falling
Enable Int0

Enable Interrupts

'Variablen definieren


Dim Timetic  As Word                                        'Z�hler f�r OP-Signal
Dim PAStic  As Word                                         'Dauer zwischen zwei PAS-Signalen
Dim PASticCumulated  As Word                                'Zur Filterung aufaddierte Dauer zwischen zwei PAS-Signalen
Dim PAScounter  As Word                                     'Z�hler f�r PAS-Signal
Dim Torquecounter As Word                                   'Z�hler f�r Torque-Signal
Dim TorqueCumulated As Word                                   'zur filterung aufaddierter Z�hler f�r Torque-Signal
Dim Temp As Word                                            'Zwischenvariable f�r Mehrfacharithmetik
Dim Torque As Word                                          'Ausgang f�r analoges Torquesignal PWM auf PB0
Dim ExtFlag As Bit
'Variablen initialisieren



Timetic=0
Torque=0
PAStic=32000
Torquecounter=0
PAScounter=0


'Start Hauptschleife

Do

If ExtFlag = 1 Then

   If Timetic < 2 Then                                 'Hier nachdenken, anpassen.
      Temp =  TorqueCumulated/4
      TorqueCumulated = TorqueCumulated - Temp
      Temp = Timetic * 256
      Temp = Temp + Torquecounter
      ' hier noch Plausicheck einf�gen...
      TorqueCumulated = TorqueCumulated + Temp
      Torque =  TorqueCumulated/8
      Ocr0A =   Torque mod 255
      if Torque > 255 then                           'Durch toggle im Sender z�hlt Empf�nger bei gleicher Timereinstellung doppelt so viel Werte
     ' toggle Portb.3
      endif
   Else
      Temp = PASticCumulated/3
      PASticCumulated = PASticCumulated - Temp           'PAS Signal �ber drei Werte Filtern, da jede dritte L�cke schmaler ist.
      PASticCumulated = PASticCumulated + PAScounter
      PAStic =  PASticCumulated/3
      PAScounter = 0
      toggle Portb.3

   Endif

   'PAS-Pin setzen
   Temp = PAStic/2
   If PAScounter < Temp then
      Portb.4 = 0
   Else
      Portb.4 = 1
   Endif


   'Ocr0B = Torquecounter
   ExtFlag = 0                                         'Flag vom externen Interrupt zur�cksetzen
   Timetic = 0                                         'Timer1 overflowz�hler zur�cksetzen, Z�hler wird inkrementiert, wenn die Torquepulsfolge nicht anliegt.
EndIf



Loop




Tick:
                                              'interruptroutine f�r Timer0
If PAScounter < 32000 Then
incr PAScounter
Endif

Return


ExtInterrupt:
Torquecounter= Timer1
Timer1=0
ExtFlag = 1

Return

Tim1Ovf:

If Timetic < 32000 Then
incr Timetic
Endif
Return