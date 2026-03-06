import pandas as pd
import numpy as np
# FIG1: Distribution of indegree and outdegree
df_node_property = pd.read_csv(\to\path\node_property.csv)
indegree_count = df_node_property["source"].value_counts().values
outdegree_count = df_node_property["target"].value_counts().values
def get_pdf_and_ccdf(degree):
  degree = np.array(degree)
  bins = 150
  pdf_counts, bin_edges = np.histogram(degree, bins = bins, density = True)
  bin_centers = 0.5*(bin_edges[1:]+bin_edges[:-1])
  bin_width = np.diff(bin_edges)
  prob_mass = pdf_counts * bin_width
  ccdf = prob_mass[::-1].cumsum()[::-1]
  return bin_centers, pdf_counts, ccdf
in_bin, in_pdf, in_ccdf = get_pdf_and_ccdf(indegree_count)
out_bin, out_pdf, out_ccdf = get_pdf_and_ccdf(outdegree_count)

fig, axs = plt.subplots(2, 2, figsize = (12,10))
axs[0, 0].plot(in_bin, in_pdf, marker="o", linewidth=1.3, color="blue", markersize=5)
axs[0, 0].set_xscale('log')
axs[0, 0].set_yscale('log')
#axs[0, 0].set_title('Indegree PDF')
axs[0, 0].set_xlabel('Indegree',fontsize = 20)
axs[0, 0].set_ylabel('PDF',fontsize = 20)
#axs[0, 0].grid(True)
axs[0, 0].tick_params(axis='both', which='both', labelsize=16) 
# Indegree CCDF
axs[0, 1].scatter(in_ccdf_x, in_ccdf_y, color='red', s=20)
axs[0, 1].set_xscale('log')
axs[0, 1].set_yscale('log')
#axs[0, 1].set_title('Indegree CCDF')
axs[0, 1].set_xlabel('Indegree',fontsize = 20)
axs[0, 1].set_ylabel('CCDF',fontsize = 20)
#axs[0, 1].grid(True)
axs[0, 1].tick_params(axis='both', which='both', labelsize=16) 
# Outdegree PDF
axs[1, 0].plot(out_bin, out_pdf, marker="o", linewidth=1.3, color="blue", markersize=5)
axs[1, 0].set_xscale('log')
axs[1, 0].set_yscale('log')
#axs[1, 0].set_title('Outdegree PDF')
axs[1, 0].set_xlabel('Outdegree',fontsize = 20)
axs[1, 0].set_ylabel('PDF',fontsize = 20)
#axs[1, 0].grid(True)
axs[1, 0].tick_params(axis='both', which='both', labelsize=16) 
# Outdegree CCDF
axs[1, 1].scatter(out_ccdf_x, out_ccdf_y, color='red', s=20)
axs[1, 1].set_xscale('log')
axs[1, 1].set_yscale('log')
#axs[1, 1].set_title('Outdegree CCDF')
axs[1, 1].set_xlabel('Outdegree',fontsize = 20)
axs[1, 1].set_ylabel('CCDF',fontsize = 20)
#axs[1, 1].grid(True))


  
