from wavemeter_dashboard.controller.arduino_dac import DAC

dac = DAC("COM8")

print("test")

print(dac.get_dac_value(2))
dac.set_dac_inc(2, 10)
print(dac.get_dac_value(2))