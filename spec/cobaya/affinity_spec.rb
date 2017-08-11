require 'spec_helper'
require 'os'

RSpec::describe Cobaya::Affinity do
  it 'sets the cpu affinity' do
    if OS.linux?
      cpu_id = Cobaya::Affinity.choose_available_cpu

      taskset_result_raw = `taskset -cp #{Process::pid}`.chomp
      cpu_aff = taskset_result_raw.split(':')[1].chomp.split('-').map(&:to_i)

      expect([cpu_id]).to eq cpu_aff
    else
      # Catch exception
    end
  end
end
