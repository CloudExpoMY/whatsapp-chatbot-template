module DescProcessor
  extend ActiveSupport::Concern

  ABBREVIATIONS = {
    'PT' => 'PROTON',
    'TY' => 'TOYOTA',
    'KIA' => 'KIA',
    'SZ' => 'SUZUKI',
    'HD' => 'HONDA',
    'FD' => 'FORD',
    'HY' => 'HYUNDAI',
    'AT' => 'AUDI',
    'NS' => 'NISSAN',
    'VV' => 'VOLVO',
    'MIT' => 'MITSUBISHI',
    'MZ' => 'MAZDA',
    'ISZ' => 'ISUZU',
    'PG' => 'PEUGEOT',
    'BMW' => 'BMW',
    'AF' => 'ALFA ROMEO',
    'SB' => 'SUBARU',
    'VW' => 'VOLKSWAGEN',
    'CHV' => 'CHEVROLET',
    'DHS' => 'DAIHATSU',
    'BM' => 'BENZ',
    'SY' => 'SSANGYONG',
    'MB' => 'MITSUBISHI',
    'LH' => 'LAND ROVER',
    'IZ' => 'ISUZU',
    'MT' => 'MITSUBISHI',
    'PR' => 'PERODUA',

    'LWR' => 'LOWER',
    'UPR' => 'UPPER',
    'LW' => 'LOWER',
    'UP' => 'UPPER',
    'LH' => 'LEFT HAND',
    'RH' => 'RIGHT HAND',
    'FR' => 'FRONT',
    'RR' => 'REAR',
    'FRT' => 'FRONT'
  }

  included do
    before_save :expand_description
  end

  def expand_description
    output = description.dup
    ABBREVIATIONS.each do |abbr, full_form|
      pattern = Regexp.union(/\b#{abbr}\b/i, /\b#{full_form}\b/i)
      output.gsub!(pattern) { |_match| "#{abbr} #{full_form}" }
    end
    self.desc_expanded = output
  end

  class_methods do
    def preprocess_query(query)
      processed_query = query.dup
      ABBREVIATIONS.each do |abbr, full_form|
        processed_query.gsub!(/\b#{full_form}\b/i, abbr)
      end
      processed_query
    end

    def fetch_brand_abbr
      descriptions = Product.distinct.pluck(:description)
      abbreviation_regex = %r{(\b[A-Z]{2,3})/}
      abbreviations = descriptions.flat_map do |desc|
        desc.scan(abbreviation_regex).flatten
      end

      abbreviations.uniq
    end
  end
end
