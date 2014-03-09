# Mock model constructed for the tests
class Model
  ALL = %w(a b c)
  class << self
    def all; ALL.map{ |e| Model.new({:data=> e }) }; end
    def find(id)
      if id.to_i < ALL.length
        Model.new({:data => ALL[id.to_i]})
      else
        raise ActiveRecord::RecordNotFound
      end
    end
    def create(param); me = self.new(param); me.save; me; end
  end
  def initialize(param); @data = param[:data]; self; end
  def save
    unless @data.nil? || @data.match(/[\d]+/)
      ALL.push(@data) unless ALL.include?(@data)
      true
    else
      false
    end
  end
  def update_attributes params
    if params[:data] != @data
      unless params[:data].match(/[\d]+/)
        ALL[ALL.index(@data)] = params[:data]
        @data = params[:data]
        true
      else
        false
      end
    end
  end
  def destroy
    if ALL.include? @data
      ALL.delete @data
      true
    else
      false
    end
  end
  def reflections
    {:models => Hash.new}
  end
  def models
    Model
  end
  def errors; []; end
end