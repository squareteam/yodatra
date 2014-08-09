# Mock model constructed for the tests
class ArModel < ActiveRecord::Base
end

ActiveRecord::Base.establish_connection(:adapter => 'fake')
ActiveRecord::Base.connection.merge_column('ar_models', :email, :string)
ActiveRecord::Base.connection.merge_column('ar_models', :name, :string)
