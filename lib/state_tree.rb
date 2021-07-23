
class StateTree
  def self.determine_state_from_children children_state_list
    if children_state_list.include?(:failed)
      :failed
    elsif children_state_list.include?(:processing)
      :processing
    elsif children_state_list.select{|state| :created == state}.size == children_state_list.size
      :created
    elsif children_state_list.select{|state| :completed == state}.size == children_state_list.size
      :completed
    else
      :undefined
    end
  end
end
