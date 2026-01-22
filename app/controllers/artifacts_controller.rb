class ArtifactsController < ApplicationController
  # set_artifact will now look for the artifact WITHIN the current tenant scope automatically
  before_action :set_artifact, only: %i[show edit update destroy]
  before_action :set_project, only: %i[new create]
  before_action :check_premium_limit, only: [:new, :create]

  def check_premium_limit
    @project = Project.find(params[:project_id])
    if current_tenant.plan != 'premium' && @project.artifacts.count >= 2
      redirect_to checkout_path, alert: "Free plan limit reached (2 artifacts). Please upgrade to continue!"
    end
  end
  # GET /artifacts
  def index
    # acts_as_tenant ensures @artifacts only contains records for the current organization
    @artifacts = Artifact.all
  end

  def show
  end

  # GET /projects/:project_id/artifacts/new
  def new
    @artifact = @project.artifacts.build
  end

  def edit
  end

  # POST /projects/:project_id/artifacts
  def create
    @artifact = @project.artifacts.build(artifact_params)

    if @artifact.save
      # Redirecting to the project show page is standard SaaS UX
      redirect_to @project, notice: "Artifact was successfully uploaded to Cloudinary."
    else
      # We need to render :new so validation errors show up on the form
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /artifacts/1
  def update
    if @artifact.update(artifact_params)
      redirect_to @artifact.project, notice: "Artifact was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /artifacts/1
  def destroy
    project = @artifact.project
    @artifact.destroy!

    # Redirect back to the project after deletion
    redirect_to project, notice: "Artifact was successfully deleted.", status: :see_other
  end

  private

  def set_project
    # Ensures the project belongs to the tenant before attaching a file
    @project = Project.find(params[:project_id])
  end

  def set_artifact
    # acts_as_tenant handles the security; this will 404 if the ID belongs to another tenant
    @artifact = Artifact.find(params[:id])
  end

  def artifact_params
    # :upload is the Active Storage attachment field
    params.require(:artifact).permit(:name, :upload)
  end
end