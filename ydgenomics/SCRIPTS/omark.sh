source /opt/software/miniconda3/bin/activate && conda activate optdntra


omamer search \
--db /data/input/Files/yangdong/SOFTWARE/OMArk/LUCA.h5 \
--query /data/work/optDNTRA_out1/results/02-optimization/03-transEvidence/transcript.flt.final.pep \
--out query.omamer \
--nthreads 8

# 1. 下载 NCBI 分类数据库压缩包
wget https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

# 2. 解压到指定目录，例如 /path/to/your/taxonomy/
mkdir -p /data/work/taxonomy/
# tar -xzf taxdump.tar.gz -C /data/work/taxonomy/ # 手动解压并没有拿到sqlie文件
python << EOF
from ete3 import NCBITaxa
import os

# 指定包含 .dmp 文件的目录
dmp_dir = "/data/work/omark_db"
# 指定输出数据库路径
db_path = "/data/work/omark_db/taxa.sqlite"

# 使用 dmp 文件构建数据库
ncbi = NCBITaxa(dbfile=db_path, taxdump_dir=dmp_dir)
print(f"Database created at {db_path}")
EOF



# 1. 在有网络的环境中运行
python -c "from ete3 import NCBITaxa; NCBITaxa()"
# 2. 找到生成的数据库文件
ls -lh ~/.etetoolkit/taxa.sqlite
# 3. 复制到你的工作目录
cp ~/.etetoolkit/taxa.sqlite /data/work/omark_db/

# 设置环境变量，让 ETE3 知道去哪里找数据库，禁止其联网更新
export ETE_NCBI_TAXDUMP=/data/work/taxonomy/
export ETE_NCBI_TAXDUMP_VERSION=latest
export ETE_NO_AUTO_UPDATE=1

# 运行 OMArk
omark \
--file query.omamer \
--database /data/input/Files/yangdong/SOFTWARE/OMArk/LUCA.h5 \
--outputFolder omark_output \
--taxid 4530  # 关键：必须提供你的物种的taxid