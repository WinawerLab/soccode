SOC
===

fMRI analysis of visual responses using the "Second-Order Contrast" model (Kay, Winawer, et al.)


Image data structures
===
cell: A cell array of C categories, each containing a matrix of images shaped X pixels * Y pixels * F frames.
      The file "stimulus.mat" from the website has this form.

stack: A matrix X * Y * C * F. Can also have a fifth dimension B for bands.
      This structure most easily allows slicing and indexing, for visualizing images.

flat: A matrix (X*Y) * (C*F) * B, where each image has been turned into a vector, and category boundaries have
      been removed, although band distinctions remain. The "model steps" mostly operate on flattened images.

pixel vector: A matrix (X*Y) * C * F, where each image has been turned into a vector, but category
      boundaries remain. The Kendrick-style model fitting code expects something like a pixel vector,
      but with the dimensions flipped to be C * (X*Y) * F.