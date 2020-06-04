class HolidaysController < ApplicationController
  unloadable
  
  before_filter(:check_plugin_right)
  
  def check_plugin_right
    right = (!Setting.plugin_mega_calendar['allowed_users'].blank? && Setting.plugin_mega_calendar['allowed_users'].include?(User.current.id.to_s) ? true : false)
    if !right
      flash[:error] = translate 'no_right'
      redirect_to({:controller => :welcome})
    end
  end

  def index
    limit = 200
    offset = 0
    @new_page = 1
    @last_page = 0
    if !params[:page].blank? && params[:page].to_i >= 1
      offset = params[:page].to_i * limit
      @new_page = params[:page].to_i + 1
      @last_page = params[:page].to_i - 1
    end
    #@res = Holiday.limit(limit).offset(offset).order(:user_id)
    #@pagination = (Holiday.count.to_f / 20.to_f) > 1.to_f
    puts ":= ========================================================="
    puts params.inspect
    if !params[:holiday].blank?
      if !params[:holiday][:user_id].blank?
        puts params[:holiday][:user_id]
        @res = Holiday.limit(limit)
                      .where(:user_id => params[:holiday][:user_id])
                      .offset(offset)
                      .order(:start)
      else
        @res = Holiday.limit(limit).offset(offset).order(:user_id)
      end
    else
      puts "NONE"
      @res = Holiday.limit(limit).offset(offset).order(:user_id)
    end
    #@pagination = (Holiday.count.to_f / 20.to_f) > 1.to_f
    puts ":= ========================================================="
  end

  def new
    #DO NOTHING
  end

  def show
    @holiday = Holiday.where(:id => params[:id]).first rescue nil
    if @holiday.blank?
      redirect_to(:controller => 'holidays', :action => 'index')
    end
  end

  def create
    @holiday = Holiday.new(params[:holiday])
    if @holiday.save
      redirect_to(:controller => 'holidays', :action => 'show', :id => @holiday.id)
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@holiday) }
      end
    end
  end

  def edit
    @holiday = Holiday.find(params[:id]) rescue nil
    if @holiday.user_id != User.current.id and not User.current.admin
      render_error :status => 403, :message => "Access denied."
      return
    end
    if @holiday.blank?
      redirect_to(:controller => 'holidays', :action => 'index')
    end
  end

  def update
    @holiday = Holiday.find(params[:holiday][:id]) rescue nil
    if @holiday.user_id != User.current.id and not User.current.admin
      render_error :status => 403, :message => "Access denied."
      return
    end
    @holiday.assign_attributes(params[:holiday])
    if @holiday.save
      redirect_to(:controller => 'holidays', :action => 'show', :id => @holiday.id)
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@holiday) }
      end
    end
  end

  def destroy
    holiday = Holiday.where(:id => params[:id]).first rescue nil
    if holiday.user_id != User.current.id and not User.current.admin
      render_error :status => 403, :message => "Access denied."
      return
    end
    holiday.destroy()
    redirect_to(:controller => 'holidays', :action => 'index')
  end
end
