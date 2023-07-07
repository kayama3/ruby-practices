# frozen_string_literal: true

class FilePathsCollector
  def initialize(dotmatch, reverse)
    @dotmatch = dotmatch
    @reverse = reverse
  end

  def collect
    file_paths = @dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    @reverse ? file_paths.reverse : file_paths
  end
end
