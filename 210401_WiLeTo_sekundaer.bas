'Pedelegalizer 0.9
$regfile = "attiny85.dat"
$crystal = 8000000
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'Analog in initialisieren

Config Adc = Single , Prescaler = Auto , Reference = Avcc
Start Adc

'Timer f�r PWM initialisieren



Config Timer0 = Pwm , Pwm = On , Prescale = 1 , Compare A Pwm = Clear up , Compare B Pwm = Clear up
Enable Timer0
Start Timer0
Ocr0a = 128

'Ein- und Ausg�nge initialisieren



Config Portb.3 = Input                                      'PB3 f�r Drehmoment einlesen
Config Portb.4 = Output                                     'PB4 Ausgang f�r Blinkfrequenz der LEDs
Config Portb.0 = Output                                     'PWM Ausgang f�r Nullpunktseinstellung



'Interrupts initialisieren


OCR1C = 127                                                 'f�r CTC auf Timer1 mu� OCR1C gesetzt werden, nicht OCR1A, nach langem Lesen herausgefunden :-)



Config Timer1 = TIMER , Prescale = 8 , CLEAR_TIMER = 1 , Compare A = Disconnect


On Oc1a Tick
Enable Oc1a
Start Timer1

Enable Interrupts

'Variablen definieren

Dim Flagtime As Bit                                         'Flag f�r Timerinterrupt
Dim Timetic  As Word                                        'Z�hler f�r Taktung Drehmoment Messung
Dim Torquetic As Word                                       'Z�hler f�r Pulsfrequenz Drehmomentsignal
Dim Torqueneu As Word                                       'Analogwert Drehmoment
Dim Torque As Word                                          'Analogwert Drehmoment
Dim Pulsdauer As Word                                       'Vorgabewert Pulsdauer
Dim Temp As Word                                            'zwischenspeicher f�r Berechnungen
Dim 2xPulsdauer as Word
'Variablen initialisieren

Flagtime = 0
Pulsdauer = 10
2xPulsdauer = Pulsdauer *2
Timetic=0

waitms 2000
'Nullpunkt einstellen

Torqueneu = Getadc(3)
while Torqueneu<82                                          'so lange Signal kleiner 0,4V (5V bei 10bit Aufl�sung) PWM erh�hen
      incr Ocr0a
      waitms 10
      Torqueneu = Getadc(3)
Wend

while Torqueneu>164                                         'so lange Signal gr��er 0,8V (5V bei 10bit Aufl�sung) PWM reduzieren
      decr Ocr0a
      waitms 10
      Torqueneu = Getadc(3)
Wend



'Start Hauptschleife

Do
waitms 100
Temp = Getadc(3)/4
'Ocr0a = 255

OCR1C = Temp
Loop




Tick:
                                              'interruptroutine f�r Timer1
toggle portb.4
Return