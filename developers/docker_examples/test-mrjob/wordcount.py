"""The classic MapReduce job: count the frequency of words.
"""
from mrjob.job import MRJob
import happybase
import re

WORD_RE = re.compile(r"[\w']+")


class MRWordFreqCount(MRJob):

    def mapper(self, _, line):
        for word in WORD_RE.findall(line):
            yield (word.lower(), 1)

    def combiner(self, word, counts):
        yield (word, sum(counts))

    def reducer_init(self):
        pass
        self.hbase = happybase.Connection("10.0.88.76",
                                     9090)
                                    # table_prefix="edinet",
                                    # table_prefix_separator=":"
                                    # )
        self.hbase.open()
        try:
            self.hbase.create_table("test",{"m":dict()})
        except:
            pass

    def reducer(self, word, counts):
        t = self.hbase.table("test")
        res = sum(counts)
        t.put(word,{"m:1":str(res)})
        yield (word, res)


if __name__ == '__main__':
     MRWordFreqCount.run()
