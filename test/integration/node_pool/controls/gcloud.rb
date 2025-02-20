# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

project_id = attribute('project_id')
location = attribute('location')
cluster_name = attribute('cluster_name')

expected_accelerators_count = "1"
expected_accelerators_type = "nvidia-tesla-p4"

control "gcloud" do
  title "Google Compute Engine GKE configuration"
  describe command("gcloud --project=#{project_id} container clusters --zone=#{location} describe #{cluster_name} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let!(:data) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "node pools" do
      let(:node_pools) { data['nodePools'].reject { |p| p['name'] == "default-pool" } }

      it "has 3" do
        expect(node_pools.count).to eq 3
      end

      describe "pool-01" do
        it "exists" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
            )
          )
        end

        it "is the expected machine type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "config" => including(
                "machineType" => "n1-standard-2",
              ),
            )
          )
        end

        it "has autoscaling enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "autoscaling" => including(
                "enabled" => true,
              ),
            )
          )
        end

        it "has the expected minimum node count" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "autoscaling" => including(
                "minNodeCount" => 1,
              ),
            )
          )
        end

        it "has autorepair enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "management" => including(
                "autoRepair" => true,
              ),
            )
          )
        end

        it "has automatic upgrades enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "management" => including(
                "autoUpgrade" => true,
              ),
            )
          )
        end

        it "has the expected metadata" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "config" => including(
                "metadata" => including(
                  "shutdown-script" => File.open("examples/node_pool/data/shutdown-script.sh").read,
                  "disable-legacy-endpoints" => "false",
                ),
              ),
            )
          )
        end

        it "has the expected labels" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "config" => including(
                "labels" => {
                  "all-pools-example" => "true",
                  "pool-01-example" => "true",
                  "cluster_name" => cluster_name,
                  "node_pool" => "pool-01",
                },
              ),
            )
          )
        end

        it "has the expected network tags" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "config" => including(
                "tags" => match_array([
                  "all-node-example",
                  "pool-01-example",
                  "gke-#{cluster_name}",
                  "gke-#{cluster_name}-pool-01",
                ]),
              ),
            )
          )
        end
      end

      describe "pool-02" do
        it "exists" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
            )
          )
        end

        it "is the expected machine type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "machineType" => "n1-standard-2",
              ),
            )
          )
        end

        it "has autoscaling enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "autoscaling" => including(
                "enabled" => true,
              ),
            )
          )
        end

        it "has the expected minimum node count" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "autoscaling" => including(
                "minNodeCount" => 1,
              ),
            )
          )
        end

        it "has the expected maximum node count" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "autoscaling" => including(
                "maxNodeCount" => 2,
              ),
            )
          )
        end

        it "has the expected accelerators" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "accelerators" => [{"acceleratorCount" => expected_accelerators_count,
                                    "acceleratorType" => expected_accelerators_type}],
              ),
            )
          )
        end

        it "has the expected disk size" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "diskSizeGb" => 30,
              ),
            )
          )
        end

        it "has the expected disk type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "diskType" => "pd-standard",
              ),
            )
          )
        end

        it "has the expected image type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "imageType" => "COS",
              ),
            )
          )
        end

        it "has the expected labels" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "labels" => including(
                  "all-pools-example" => "true",
                  "cluster_name" => cluster_name,
                  "node_pool" => "pool-02",
                )
              ),
            )
          )
        end

        it "has the expected network tags" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "tags" => match_array([
                  "all-node-example",
                  "gke-#{cluster_name}",
                  "gke-#{cluster_name}-pool-02",
                ])
              ),
            )
          )
        end
      end
      describe "pool-03" do
        it "exists" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-03",
            )
          )
        end
        it "is the expected machine type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-03",
              "config" => including(
                "machineType" => "n1-standard-2",
              ),
            )
          )
        end

        it "has autoscaling enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-03",
              "autoscaling" => including(
                "enabled" => true,
              ),
            )
          )
        end

        it "has the expected minimum node count" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-03",
              "autoscaling" => including(
                "minNodeCount" => 1,
              ),
            )
          )
        end

        it "has autorepair enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-03",
              "management" => including(
                "autoRepair" => true,
              ),
            )
          )
        end

        it "has automatic upgrades enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-03",
              "management" => including(
                "autoUpgrade" => true,
              ),
            )
          )
        end

      end
    end
  end
  describe command("gcloud beta --project=#{project_id} container clusters --zone=#{location} describe #{cluster_name} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let!(:data) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    it "pool-03 has nodes in correct locations" do
      expect(data['nodePools']).to include(
        including(
          "name" => "pool-03",
          "locations" => match_array([
            "us-east4-b",
            "us-east4-c",
          ]),
        )
      )
    end
  end
end
