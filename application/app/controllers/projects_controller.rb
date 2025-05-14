class ProjectsController < ApplicationController

  def index
    @projects = Project.all
    @active_project = Project.find(Current.settings.user_settings.active_project.to_s)
  end

  def show
    @project = Project.find(params[:id])
  end

  def create
    project_name = params[:project_name] || ProjectNameGenerator.generate
    project = Project.new(id: project_name, name: project_name)
    if project.save
      flash[:notice] = "Project #{project_name} created"
    else
      flash[:alert] = "Error generating the project: #{project.errors.full_messages}"
    end

    redirect_to projects_path
  end

  def update
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      error_message = "Project #{project_id} not found"
      respond_to do |format|
        format.html { redirect_to projects_path, alert: error_message }
        format.json { render json: { error: error_message }, status: :not_found }
      end
      return
    end

    update_params = params.permit(:name, :download_dir).to_h.compact

    if project.update(update_params)
      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'Project updated successfully' }
        format.json { render json: project.to_json, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to projects_path, alert: "Failed to update project: #{project.errors.full_messages}" }
        format.json { render json: { error: project.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def set_active
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      redirect_to projects_path, alert: "Project #{project_id} not found"
      return
    end

    Current.settings.update_user_settings({active_project: project_id})
    redirect_to projects_path, notice: "#{project.name} is now the active project."
  end

  def destroy
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      redirect_to projects_path, alert: "Project #{project_id} not found"
      return
    end

    project.destroy
    redirect_to projects_path, notice: "Project #{project.name} deleted successfully"
  end
end
