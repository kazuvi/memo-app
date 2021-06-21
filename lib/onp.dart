formatDiff(prev, curr, result) {
        var index = [0, 0]; // [prev, curr]
        var string = "distance: " + result[0].toString() + "<br>" + "\n";

        for (var i = 0; i < result[1].length; i++) {
            if (index[1] < result[1][i][1]) {
                string += ' +';
                while (index[1] < result[1][i][1]) {
                    string += curr[index[1]];
                    index[1]++;
                }
                string += ' ';
            }
            if (index[0] < result[1][i][0]) {
                string += ' -';
                while (index[0] < result[1][i][0]) {
                    string += prev[index[0]];
                    index[0]++;
                }
                string += ' ';
            }
            string += prev[result[1][i][0]];
            index[0]++;
            index[1]++;
        }
        if (index[1] < curr.length) {
            string += ' +';
            while (index[1] < curr.length) {
                string += curr[index[1]];
                index[1]++;
            }
            string += ' ';
        }
        if (index[0] < prev.length) {
            string += ' -';
            while (index[0] < prev.length) {
                string += prev[index[0]];
                index[0]++;
            }
            string += ' ';
        }
        print(string);
        return string;
    }

onp(A, B) {
  var N = A.length;
  var M = B.length;
  if (N < M) {
            var result = onp(B, A);
            for (var i = 0; i < result[1].length; i++) {
                var tmp = result[1][i][0];
                result[1][i][0] = result[1][i][1];
                result[1][i][1] = tmp;
            }
            return result;
        }
        int delta = N - M;
        var fp = [];
        int offset = M + 1;
        for (var i = 0; i < M + N + 3; i++) {
            fp.add([-1, []]);
        }
        fp[0 + offset][0] = 0;
        for (var p = 0;; p++) {
            for (int k = -p; k < delta; k++) {
                var tmp;
                if (fp[k - 1 + offset][0] + 1 > fp[k + 1 + offset][0]) {
                    tmp = fp[k - 1 + offset];
                    tmp[0]++;
                } else {
                    tmp = fp[k + 1 + offset];
                }
                var result = goDiagonally(A, B, k, tmp[0]);
                fp[k + offset][0] = result[0];
                fp[k + offset][1] = tmp[1] + result[1];
            }
            for (int k = p + delta; k > delta; k--) {
                var tmp;
                if (fp[k - 1 + offset][0] + 1 > fp[k + 1 + offset][0]) {
                    tmp = fp[k - 1 + offset];
                    tmp[0]++;
                } else {
                    tmp = fp[k + 1 + offset];
                }
                var result = goDiagonally(A, B, k, tmp[0]);
                fp[k + offset][0] = result[0];
                fp[k + offset][1] = tmp[1] + result[1];
            }
            {
                var tmp;
                if (fp[delta - 1 + offset][0] + 1 > fp[delta + 1 + offset][0]) {
                    tmp = fp[delta - 1 + offset];
                    tmp[0]++;
                } else {
                    tmp = fp[delta + 1 + offset];
                }
                var result = goDiagonally(A, B, delta, tmp[0]);
                fp[delta + offset][0] = result[0];
                fp[delta + offset][1] = tmp[1] + result[1];
            }
            if (fp[delta + offset][0] == N) {
                return [delta + 2 * p, fp[delta + offset][1]];
            }
        }
}

goDiagonally(A, B, k, y) {
        var x = y - k;
        var common = [];
        if (y < A.length && x < B.length) {
        }
        while (y < A.length && x < B.length && A[y] == B[x]) {
            common.add([y, x]);
            x++;
            y++;
        }
        return [y, common];
    }
