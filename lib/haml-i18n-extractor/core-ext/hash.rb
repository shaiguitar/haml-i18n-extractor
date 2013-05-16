# @date = Hash.recursive_init
# @date[month][day][hours][min][sec] = 1
# @date now equals {month=>{day=>{hours=>{min=>{sec=>1}}}}}
class Hash
  def self.recursive_init
    new do |hash, key|
      unless key.nil?
        hash[key] = recursive_init
      end
    end
  end
end

require 'active_support/core_ext/hash/deep_merge'
