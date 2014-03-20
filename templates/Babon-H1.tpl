<chart>
symbol=EURJPY
period=60
leftpos=9314
digits=3
scale=8
graph=1
fore=0
grid=0
volume=1
scroll=1
shift=0
ohlc=0
askline=0
days=0
descriptions=0
shift_size=20
fixed_pos=0
window_left=1129
window_top=-1
window_right=1362
window_bottom=477
window_type=3
background_color=12632256
foreground_color=0
barup_color=13434880
bardown_color=0
bullcandle_color=13434880
bearcandle_color=0
chartline_color=0
volumes_color=-1
grid_color=0
askline_color=-1
stops_color=-1

<window>
height=119
<indicator>
name=main
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=TMA
flags=19
window_num=0
<inputs>
TimeFrame=60
HalfLength=20
Price=0
ATRMultiplier=2.00000000
ATRPeriod=100
Interpolate=1
alertsOn=0
alertsOnCurrent=0
alertsOnHighLow=0
alertsMessage=0
alertsSound=0
alertsEmail=0
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=-1
style_0=2
weight_0=0
shift_1=0
draw_1=0
color_1=16711680
style_1=0
weight_1=2
shift_2=0
draw_2=0
color_2=16711680
style_2=0
weight_2=2
period_flags=16
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=TMA
flags=19
window_num=0
<inputs>
TimeFrame=240
HalfLength=20
Price=0
ATRMultiplier=2.00000000
ATRPeriod=100
Interpolate=1
alertsOn=0
alertsOnCurrent=0
alertsOnHighLow=0
alertsMessage=0
alertsSound=0
alertsEmail=0
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=16777215
style_0=2
weight_0=0
shift_1=0
draw_1=0
color_1=1262987
style_1=0
weight_1=3
shift_2=0
draw_2=0
color_2=1262987
style_2=0
weight_2=3
period_flags=48
show_data=1
</indicator>
</window>

<window>
height=42
<indicator>
name=Custom Indicator
<expert>
name=Heiken Ashi
flags=339
window_num=0
<inputs>
color1=255
color2=16777215
color3=255
color4=16777215
</inputs>
</expert>
shift_0=0
draw_0=2
color_0=255
style_0=0
weight_0=1
shift_1=0
draw_1=2
color_1=16777215
style_1=0
weight_1=1
shift_2=0
draw_2=2
color_2=255
style_2=0
weight_2=3
shift_3=0
draw_3=2
color_3=16777215
style_3=0
weight_3=3
period_flags=48
show_data=1
</indicator>
</window>

<window>
height=50
<indicator>
name=Custom Indicator
<expert>
name=TDI Red Green
flags=19
window_num=2
<inputs>
RSI_Period=13
RSI_Price=0
Volatility_Band=34
RSI_Price_Line=2
RSI_Price_Type=0
Trade_Signal_Line=7
Trade_Signal_Type=0
</inputs>
</expert>
shift_0=0
draw_0=12
color_0=0
style_0=0
weight_0=0
shift_1=0
draw_1=0
color_1=-1
style_1=0
weight_1=0
shift_2=0
draw_2=0
color_2=-1
style_2=0
weight_2=0
shift_3=0
draw_3=0
color_3=-1
style_3=0
weight_3=0
shift_4=0
draw_4=0
color_4=32768
style_4=0
weight_4=2
shift_5=0
draw_5=0
color_5=255
style_5=0
weight_5=2
levels_color=6908265
levels_style=2
levels_weight=1
level_0=50.0000
level_1=68.0000
level_2=32.0000
period_flags=48
show_data=1
</indicator>
</window>
</chart>
