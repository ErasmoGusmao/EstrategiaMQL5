<chart>
id=131000198163556901
symbol=EMBR3
period_type=1
period_size=24
digits=2
tick_size=0.010000
position_time=1446681600
scale_fix=0
scale_fixed_min=25.720000
scale_fixed_max=30.870000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=1
fore=0
grid=1
volume=2
scroll=1
shift=0
shift_size=19.696970
fixed_pos=0.000000
ohlc=0
one_click=0
one_click_btn=1
bidline=1
askline=0
lastline=1
days=0
descriptions=0
tradelines=1
window_left=150
window_top=150
window_right=1125
window_bottom=469
window_type=3
background_color=16777215
foreground_color=0
barup_color=0
bardown_color=0
bullcandle_color=238343
bearcandle_color=255
chartline_color=65280
volumes_color=3329330
grid_color=10061943
bidline_color=10061943
askline_color=255
lastline_color=49152
stops_color=255
windows_total=4

<window>
height=142.624772
objects=0

<indicator>
name=Main
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\Examples\BB.ex5
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=Bands(17) Middle
draw=1
style=1
width=1
arrow=251
color=0
</graph>

<graph>
name=Bands(17) Upper
draw=1
style=1
width=1
arrow=251
color=11186720
</graph>

<graph>
name=Bands(17) Lower
draw=1
style=1
width=1
arrow=251
color=2237106
</graph>
<inputs>
InpBandsPeriod=17
InpBandsShift=0
InpBandsDeviations=2.00000000
</inputs>
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=255
</graph>
period=10
method=1
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=0
</graph>
period=15
method=1
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=16711680
</graph>
period=20
method=1
</indicator>
</window>

<window>
height=36.390858
objects=0

<indicator>
name=Relative Strength Index
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=1
scale_fix_min_val=0.000000
scale_fix_max=1
scale_fix_max_val=100.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=1
style=0
width=1
arrow=251
color=0
</graph>

<level>
level=45.000000
style=0
color=255
width=1
descr=
</level>

<level>
level=60.000000
style=0
color=255
width=1
descr=
</level>
period=9
</indicator>
</window>

<window>
height=35.502406
objects=0

<indicator>
name=MACD
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=-0.612330
scale_fix_max=0
scale_fix_max_val=1.007530
expertmode=0
fixed_height=-1

<graph>
name=
draw=2
style=0
width=1
arrow=251
color=16711680
</graph>

<graph>
name=
draw=1
style=2
width=1
arrow=251
color=0
</graph>
fast_ema=12
slow_ema=26
macd_sma=9
</indicator>
</window>

<window>
height=35.481963
objects=0

<indicator>
name=Custom Indicator
path=Indicators\Examples\ADX.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=ADX(14)
draw=1
style=2
width=1
arrow=251
color=0
</graph>

<graph>
name=+DI
draw=1
style=0
width=1
arrow=251
color=16711680
</graph>

<graph>
name=-DI
draw=1
style=0
width=1
arrow=251
color=255
</graph>
<inputs>
InpPeriodADX=14
</inputs>
</indicator>
</window>
</chart>