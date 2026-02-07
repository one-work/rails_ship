module QqMapHelper
  KEY = Rails.application.credentials.dig(:qq_map, :key)
  SK = Rails.application.credentials.dig(:qq_map, :secret)
  extend CommonApi
  extend self

  def base_url
    'https://apis.map.qq.com/'
  end

  def geocoder(lat:, lng:)
    r = get 'ws/geocoder/v1', params: { location: [lat, lng].join(',') }
    result = r.json
    if result['status'] == 0
      result['result']
    else
      Rails.logger.error(result)
      result
    end
  end

  def ip(ip)
    r = get 'ws/location/v1/ip', params: { ip: ip }
    if r.status >= 200 && r.status < 300
      result = r.json
      if result['status'] == 0
        result['result']
      else
        Rails.logger.error(result)
        result
      end
    end
  end

  def districts
    r = get 'ws/district/v1/list'
    result = r.json
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
  def with_access_token(tries: 2, params: {}, headers: {}, payload: {}, path: '')
    params.merge! sign: sign_params(path, params)
    yield
  end

  def sign_params(path, body)
    r = body.sort.map(&->(i){ "#{i[0]}=#{i[1]}" }).join('&')
    body.merge! sig: Digest::MD5.hexdigest("/#{path}?#{r}#{SK}"), key: KEY
  end

end
