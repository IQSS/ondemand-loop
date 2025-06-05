# frozen_string_literal: true

# ProjectNameGenerator generates randomized, domain-relevant project names
# by combining a scientific or HPC-related adjective and noun.
# Optionally, a numeric token and custom delimiter can be included.
# Useful for assigning default names to projects in research, HPC, or data-driven environments.
class ProjectNameGenerator
  def self.generate(token_length: 2, delimiter: "_")
    adjective = adjectives.sample
    noun = nouns.sample
    token = token_length > 0 ? delimiter + rand(10**token_length).to_s.rjust(token_length, '0') : ""

    "#{adjective}#{delimiter}#{noun}#{token}"
  end

  def self.adjectives
    @adjectives ||= %w[
      quantum parallel scalable dynamic distributed virtual rapid synchronized
      intelligent autonomous efficient adaptive resilient innovative modular
      robust highspeed accelerated multithreaded elastic analytical predictive
      optimized virtualized encrypted integrated strategic collaborative
      experimental computational theoretical empirical synthetic advanced
      pioneering breakthrough expansive massive stateful multiscale versatile
      modularized persistent concurrent hybrid emergent
    ]
  end

  def self.nouns
    @nouns ||= %w[
      cluster node server pipeline dataset algorithm matrix tensor simulation
      computation accelerator array processor model architecture laboratory
      experiment framework workstation observatory core storage network
      supercomputer scheduler fabric topology queue workload jobstream
      datacenter repository compiler runtime orchestrator datalake portal
      jupyter slurm matlab rstudio python julia singularity container
      spark hadoop airflow pytorch tensorflow mpi openmp bash shell
      script module gpu
    ]
  end
end
