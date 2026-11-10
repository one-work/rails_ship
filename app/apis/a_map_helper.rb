module AMapHelper
  KEY = Rails.app.creds.option(:a_map, :key, default: nil)
  SK = Rails.app.creds.option(:amap, :code, default: nil)
  extend CommonApi
  extend self

  def base_url
    'https://restapi.amap.com/'
  end

  def geocoder(lat:, lng:)
    result = get 'ws/geocoder/v1', location: [lat, lng].join(',')
    if result['status'] == 0
      result['result']
    else
      Rails.logger.error(result)
      result
    end
  end

  def address(addr)
    result = get 'ws/geocoder/v1', address: addr
    if result['status'] == 0
      result['result']
    else
      Rails.logger.error(result)
      result
    end
  end

  def ip(ip)
    result = get 'v3/ip', ip: ip
    if result['status'] == '1'
      result['city']
    else
      Rails.logger.error(result)
      result
    end
  end

  def districts(keywords = '')
    result = get 'v3/config/district', keywords: keywords, subdistrict: 3
    if result['status'] == '1'
      result['districts'][0]
    else
      Rails.logger.error(result)
      result
    end
  end

  def sync_to_areas(results = districts, parent = nil)
    results.fetch('districts', []).each do |result|
      area = Ship::Area.find_or_initialize_by(full: result['name'])
      area.parent = parent
      area.name = result['name']
      area.code = result['citycode']
      area.save

      sync_to_areas(result, area)
    end
  end

  private
  def with_access_token(params:, path:, **)
    params.merge!(key: KEY)
    params.merge! sig: sign_params(path, params)
    yield
  end

  def sign_params(path, body)
    r = body.sort.map(&->(i){ "#{i[0]}=#{i[1]}" }).join('&')
    Digest::MD5.hexdigest("/#{path}?#{r}#{SK}")
  end

end
