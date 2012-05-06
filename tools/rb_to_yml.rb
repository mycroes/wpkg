def hash_to_yaml(hash, filename)

  def clean(s)
    s.gsub(/%(\w+)%/) { |m| m.to_s.upcase }
  end

  File.open(filename, 'w') do |f|
    hash.each_pair do |k,v|
      f.puts"- id: #{k}"
      f.puts("  package_id: #{v[0][:package_id]}") if v[0][:package_id]
      f.puts("  notice: #{v[0][:notice]}") if v[0][:notice]
      f.puts("  files:")
      v.each do |i|
        f.puts("    - url: #{clean(i[:url])}")
        f.puts("      destination: [#{clean(i[:destination].join(', '))}]")
      end
      f.puts ''
    end
  end
end

hash_to_yaml OLD_PACKAGES, 'new_packages.yml'
