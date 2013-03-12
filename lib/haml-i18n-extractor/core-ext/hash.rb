# @date = Hash.recursive_init
# @date[month][day][hours][min][sec] = 1
# @date now equals {month=>{day=>{hours=>{min=>{sec=>1}}}}}
class Hash
  def self.recursive_init
    new { |hash, key| hash[key] = recursive_init }
  end
end