class SetAbrsAbandonedDeafults < ActiveRecord::Migration
  def change
    change_column :abrs, :abandoned, :boolean, default: false
    change_column_null :abrs, :abandoned, false, false
  end
end
