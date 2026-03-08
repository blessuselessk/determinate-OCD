let schema = import ".ai/context/schema-draft.ncl" in
let TreeNode = schema.contracts.TreeNode in

let test_file = {
  type = 'File,
  metadata = {
    mime_type = "text/plain",
    size_bytes = 1024,
    digest = "sha256:file-content-hash",
  },
} | TreeNode in

let test_dir = {
  type = 'Directory,
  metadata = {
    permissions = "755",
    digest = "sha256:dir-merkle-root",
  },
} | TreeNode in

{
  file = test_file,
  dir = test_dir,
}
