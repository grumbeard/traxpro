class IssuesController < ApplicationController
  before_action :set_project, only: [:index, :new, :create, :update]

  def index
    @issues = policy_scope(Issue).order(created_at: :desc).select { |issue| issue.project == @project }
  end

  def new
    @issue = Issue.new
    @subcategories = SubCategory.all.map do |sub|
      { category_id: sub.category_id, id: sub.id, name: sub.name }
    end
  end

  def create
    @issue = Issue.new(issue_params)
    authorize @issue
    @issue.project = @project
    @map = Map.find(params[:issue][:map_id])
    if @issue.save
      params[:subcategories].each do |subcategory|
        new_categorization = Categorization.new(issue: @issue, sub_category_id: subcategory)
        new_categorization.save
      end
      redirect_to issue_map_pin_path(@issue, @map)
    else
      render 'new'
    end
  end

  def update
    @issue = Issue.find(params[:id])
    authorize @issue
    if params[:issue].present?
      @issue.x_coordinate = params[:issue][:x_coordinate]
      @issue.y_coordinate = params[:issue][:y_coordinate]
      redirect_to issue_messages_path(@issue) if @issue.save
    else
      render issue_map_pin_path(@project, @issue)
    end
  end

  private

  def issue_params
    params.require(:issue).permit(:project_id, :map_id, :title)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
