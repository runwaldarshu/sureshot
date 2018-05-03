require 'addressable/template'
require 'faraday'
require 'json'
require 'csv'

def compute_vol_change(vol1, vol2)
  vol1 = vol1.to_f
  vol2 = vol2.to_f
  #p "New : #{vol1}, Old: #{vol2}"
  change = vol1 - vol2
  ((change / vol1) * 100).round(2)
end

def compute_price_change(vol1, vol2)
  vol1 = vol1.to_f
  vol2 = vol2.to_f
  #p "New : #{vol1}, Old: #{vol2}"
  (vol1 - vol2).round(2)
end

def time_interval()

  base_uri = 'https://www.alphavantage.co/query{?function,symbol,interval,apikey,datatype}'
  apikey = '1OBOFRNE6KND478D'
  interval = '15min'
  function = 'TIME_SERIES_INTRADAY'
  datatype = 'csv'

  template = Addressable::Template.new(base_uri)

  text=File.open('nse_fut_list.txt').read
  text.gsub!(/\r\n?/, "\n")
  text.each_line do |sym|
    sym.delete!("\n")
    p "***** #{sym} *****"
    p "Volume   | Price "
    url = template.partial_expand(function: function, symbol: sym, interval: interval, apikey: apikey, datatype: datatype).pattern
    p url
    response = Faraday.get url
    p response
    data = CSV.parse(response.body)
    header = data[0]
    p data
  end
end

def sma(sym, time_period)
  base_uri = 'https://www.alphavantage.co/query{?function,symbol,interval,time_period,apikey,series_type}'
  apikey = '1OBOFRNE6KND478D'
  interval = 'daily'
  function = 'SMA'
  series_type = 'close'

  template = Addressable::Template.new(base_uri)
  url = template.partial_expand(function: function, symbol: sym, interval: interval, apikey: apikey, time_period: time_period, series_type: series_type).pattern
  #p url
  response = Faraday.get url
  if response.status == 200
    data = JSON.parse(response.body)
    #p data
    if data["Technical Analysis: SMA"] && !data["Technical Analysis: SMA"].values.empty?
      #p data["Technical Analysis: SMA"].values[0], sym, time_period
      return data["Technical Analysis: SMA"].values[0]['SMA'].to_f
    else
      p sym, response.body, time_period
      0
    end
  else
    p response
    return 0
  end
end

def compute_sma()

  text=File.open('nse_fut_list.txt').read
  text.gsub!(/\r\n?/, "\n")
  text.each_line do |sym|
    sym.delete!("\n")
    old_sym = sym
    sym = 'NSE:' + sym
    if sma(sym, 200) <  sma(sym, 2)
      p old_sym
    end
  end
end

compute_sma()

