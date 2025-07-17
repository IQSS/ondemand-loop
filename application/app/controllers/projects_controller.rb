class ProjectsController < ApplicationController

  def index
    @projects = Project.all
    @active_project = Project.find(Current.settings.user_settings.active_project.to_s)
  end

  def show
    @project = Project.find(params[:id])
    redirect_to projects_path, alert: t(".project_not_found", id: params[:id]) unless @project
  end

  def create
    project_name = params[:project_name] || ProjectNameGenerator.generate
    project = Project.new(id: project_name, name: project_name)
    if project.save
      flash[:notice] = t(".project_created", project_name: project_name)
    else
      flash[:alert] = t(".project_create_error", errors: project.errors.full_messages)
    end

    redirect_to projects_path
  end

  def update
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      error_message = t(".project_not_found", id: project_id)
      respond_to do |format|
        format.html { redirect_to projects_path, alert: error_message }
        format.json { render json: { error: error_message }, status: :not_found }
      end
      return
    end

    update_params = params.permit(:name, :download_dir).to_h.compact

    if project.update(update_params)
      respond_to do |format|
        format.html { redirect_to projects_path, notice: t(".project_updated_successfully", project_name: project.name) }
        format.json { render json: project.to_json, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to projects_path, alert: t(".project_update_error", errors: project.errors.full_messages) }
        format.json { render json: { error: project.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def set_active
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      redirect_to projects_path, alert: t(".project_not_found", id: project_id)
      return
    end

    Current.settings.update_user_settings({active_project: project_id})
    redirect_to projects_path, notice: t(".project_is_now_the_active_project", project_name: project.name)
  end

  def destroy
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      redirect_to projects_path, alert: t(".project_not_found", id: project_id)
      return
    end

    project.destroy
    redirect_to projects_path, notice: t(".project_deleted_successfully", project_name: project.name)
  end
end
