import sys
import os
import time
import logging

from wavemeter_dashboard.controller.wavemeter_ws7 import WavemeterWS7
from wavemeter_dashboard.controller.fiber_switch import FiberSwitch
from wavemeter_dashboard.controller.arduino_dac import DAC
from wavemeter_dashboard.controller.wavemeter_ws7 import (
    WavemeterWS7, WavemeterWS7Exception,
    WavemeterWS7BadSignalException, WavemeterWS7LowSignalException,
    WavemeterWS7NoSignalException, WavemeterWS7HighSignalException)
from wavemeter_dashboard.util import solve_filepath
from wavemeter_dashboard import config

from pprint import pprint as pp
import numpy as np
from matplotlib import pyplot as plt
import pandas as pd

class WavemeterControl:
    #testing git
    def __init__(self):
        logging.basicConfig(filename='switch_test_log.log', filemode='a',format='%(asctime)s - %(levelname)s %(name)s %(message)s')
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.INFO)
        self.logger.debug('***Starting wavemeter controller***')
        
        self.fbs_port = 'COM10'
        self.dac_port = 'COM13'

        self.reset_all()

    def reset_all(self):
        self.logger.debug('Resetting all devices')
        self.reset_wm()
        self.reset_fs()
        self.reset_dac()

    def reset_wm(self):
        try:
            self.wm = WavemeterWS7()
            self.logger.debug('Wavemeter successfully reset')
        except Exception as me:
            self.logger.error('***Error resetting wavemeter***')
            self.wm = None

    def reset_fs(self):
        try:
            self.fs = FiberSwitch(self.fbs_port)
            self.logger.debug('Fiber switch successfully reset')
        except Exception as me:
            self.logger.error('***Error resetting fiber switch***')
            self.fs = None
        
    def reset_dac(self):
        try:
            self.dac = DAC(self.dac_port)
            self.logger.debug('DAC successfully reset')
        except Exception as me:
            self.logger.error('***Error resetting DAC***')
            self.dac = None

    def get_frequency(self):
        try:
            wl = self.wm.get_frequency() * 1e6
        except WavemeterWS7NoSignalException:
            wl = -1
        except WavemeterWS7BadSignalException:
            wl = -2
        except WavemeterWS7HighSignalException:
            wl = -3
        except WavemeterWS7LowSignalException:
            wl = -4
        except WavemeterWS7Exception:
            wl = -5
        except Exception:
            wl = -6
        return wl


def run_test(wmc, channels, saveFileName='test_data.csv', t_f=3, dt=0.02, toggle_t=4, plotData=True):
    ret = None
    if None not in [wmc.wm,wmc.fs,wmc.dac]:
        try:
            wmc.logger.debug('Resetting DAC outputs to mid range')
            wmc.dac.set_dac_value(1,wmc.dac.DAC_MAX/2)
            wmc.dac.set_dac_value(2,wmc.dac.DAC_MAX/2)
            wmc.dac.set_dac_value(0,wmc.dac.DAC_MAX/2)
            wmc.dac.set_dac_value(0,wmc.dac.DAC_MAX/2)
            wmc.logger.debug('Turning auto exposure off')
            wmc.wm.set_auto_exposure(False)
            wmc.logger.debug('Setting wavemeter exposure for channel 0')
            wmc.wm.set_exposure(channels['exp1'][0],channels['exp2'][0])
            wmc.logger.debug('Switching fiber switch to channel 0')
            wmc.fs.switch_channel(channel=channels['fs'][0])
            wmc.logger.debug('Letting things settle')
            time.sleep(.25)

            wmc.logger.debug('Setting up buffers')
            f = np.zeros(np.int64(2*(np.ceil(t_f/dt)+1)))
            t = np.zeros(np.int64(2*(np.ceil(t_f/dt)+1)))
            t_toggle = np.zeros(2)
            dt_toggle = np.zeros(2)
            idx = 0
            wmc.logger.debug('Starting t=0')
            t_0 = time.perf_counter_ns()
            t_last = t_0 - dt*1e9
            state = 0
            while t_last - t_0 <= (t_f - dt)*1e9:
                while time.perf_counter_ns() < t_0 + idx*dt*1e9:
                    pass
                t_now = time.perf_counter_ns()
                if state==0 and t_now - t_0 >= toggle_t*1e9:
                    wmc.fs.switch_channel(channel=channels['fs'][1])
                    dt_toggle[0] = (time.perf_counter_ns() - t_now)/1e9
                    t_toggle[0] = (t_now - t_0)/1e9
                    state = 1
                elif state==1 and t_now - t_0 >= 2*toggle_t*1e9:
                    wmc.wm.set_exposure(channels['exp1'][1],channels['exp2'][1])
                    dt_toggle[1] = (time.perf_counter_ns() - t_now)/1e9
                    t_toggle[1] = (t_now - t_0)/1e9
                    state = 2
                
                f[idx] = wmc.get_frequency()
                t[idx] = time.perf_counter_ns()

                if t[idx] < t_last + dt*1.9*1e9:
                    t_last = t_last + dt*1e9
                else:
                    t_last = t_now
                idx += 1
            
            t = (t[:idx]-t_0)/1e9
            f = f[:idx]

            fmax = np.max(f)
            fmin = np.min(f)
            df = fmax - fmin

            f_dash = [fmin - df/2, fmax + df/2]

            if plotData:   
                wmc.logger.debug('Plotting data') 
                if t_toggle[1]>0:
                    plt.plot(t,f,'x',
                             t_toggle[0]*np.ones(2),f_dash,'--k',(t_toggle[0]+dt_toggle[0])*np.ones(2),f_dash,'--k',
                             t_toggle[1]*np.ones(2),f_dash,'--k',(t_toggle[1]+dt_toggle[1])*np.ones(2),f_dash,'--k')
                elif t_toggle[0]>0:
                    plt.plot(t,f,'x',
                             t_toggle[0]*np.ones(2),f_dash,'--k',(t_toggle[0]+dt_toggle[0])*np.ones(2),f_dash,'--k')
                else:
                    plt.plot(t,f,'x')
                plt.ylim([fmin - df/4,fmax + df/4])
                plt.xlabel('Time (s)')
                plt.ylabel('Frequency (MHz)')
                plt.grid(True)
                plt.show()

            wmc.logger.debug('Saving data')
            df_hdr = pd.DataFrame([[i, channels['fs'][i], channels['dac'][i], channels['exp1'][0], channels['exp2'][i]]
                                    for i in range(len(channels['fs']))])
            df_hdr.to_csv(path_or_buf=saveFileName, header=['channel','fs','dac','exp1','exp2'],mode='w',index=False)
            pd.DataFrame([]).to_csv(path_or_buf=saveFileName,mode='a',index=False  )
            if t_toggle[0]>0:
                pd.DataFrame([t_toggle,dt_toggle]).to_csv(path_or_buf=saveFileName,
                                                          header=['t_toggle','dt_toggle'],mode='a',index=False  )
                pd.DataFrame([]).to_csv(path_or_buf=saveFileName,mode='a',index=False  )
                pp(dt_toggle)
            df = pd.DataFrame(np.transpose([t,f]))
            df.to_csv(path_or_buf=saveFileName, header=['t','f'], mode='a', index=False, float_format='%.6f')
            wmc.logger.debug('Done saving data')
            ret = t
        except Exception as me:
            wmc.logger.debug('Error doing the stuff')
            raise me
    else:
        print("Could not run script because components did not load properly")
    
    wmc.logger.debug('***Closing wavemeter controller***')
    return ret

if __name__=='__main__':
    wmc = WavemeterControl()
    channels = {'fs':[11,11], 'dac':[1,2], 'exp1':[100,7],'exp2':[0,0]} # corresponds to 707 and 679

    if len(sys.argv)==6:
        wmc.logger.debug('Using input arguments')
        saveFileName = sys.argv[1]
        t_f = float(sys.argv[2])
        dt = float(sys.argv[3])
        toggle_t = float(sys.argv[4])
        plotData = sys.argv[5]=='True'
        t = run_test(wmc,channels,saveFileName=saveFileName,t_f=t_f,dt=dt,toggle_t=toggle_t,plotData=plotData)
        dt = np.diff(t)    
        if plotData:
            plt.plot(t[1:],dt,'.')
            plt.show()
    else:
        run = 48
        N = 1
        wmc.logger.debug('Using default arguments')
        if not os.path.isdir('test_data/run_{run:d}'.format(run=run)):
            os.makedirs('test_data/run_{run:d}'.format(run=run))
        else:
            raise('run already exists')
        for i in range(N):
            t = run_test(wmc,channels,dt=0.0005,t_f=1.2,toggle_t=0.333,plotData=True,
                         saveFileName='test_data/run_{run:d}/run_{run:d}_rep_{rep:d}'.format(run=run,rep=i)+'.csv')
            print('{:.2f}'.format((i+1)/N*100))
        print(str())
        #dt = np.diff(t)  
        #plt.plot(t[1:],dt,'.')
        #plt.show()
