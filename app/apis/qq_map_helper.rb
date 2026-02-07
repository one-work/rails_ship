module QqMapHelper
  KEY = Rails.application.credentials.dig(:qq_map, :key)
  SK = Rails.application.credentials.dig(:qq_map, :secret)
  extend CommonApi
  extend self

  def base_url
    'https://apis.map.qq.com/'
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

  def ip(ip)
    result = get 'ws/location/v1/ip', ip: ip
    if result['status'] == 0
      result['result']
    else
      Rails.logger.error(result)
      result
    end
  end

  def districts
    result = get 'ws/district/v1/list'
    if result['status'] == 0
      result['result']
    else
      Rails.logger.error(result)
      result
    end
  end

  def sync_to_areas
    results = districts
    results[0].each do |result|
      area = Ship::Area.find_or_initialize_by(full: result['fullname'])
      area.name = result['name']
      area.code = result['id']
      area.save
    end

    results[1].each do |result|
      area = Ship::Area.find_or_initialize_by(full: result['fullname'])
      parent = Ship::Area.find_by(code: "#{result['id'][0..1]}0000")
      area.parent = parent
      area.name = result['name']
      area.code = result['id']
      area.save
    end

    results[2].each do |result|
      area = Ship::Area.find_or_initialize_by(full: result['fullname'])
      parent = Ship::Area.find_by(code: "#{result['id'][0..3]}00")
      area.parent = parent
      area.name = result['name']
      area.code = result['id']
      area.save
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
