require 'serverspec'

set :backend, :exec

describe package('nginx') do
  it { should be_installed }
end
