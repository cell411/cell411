/*
 * Copyright (C) 2018 Square, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package okio;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameter;
import org.junit.runners.Parameterized.Parameters;

import static okio.Buffer.UnsafeCursor;
import static okio.TestUtil.bufferWithRandomSegmentLayout;
import static okio.TestUtil.bufferWithSegments;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.junit.Assume.assumeTrue;

@SuppressWarnings("resource")
@RunWith(Parameterized.class)
public final class BufferCursorTest {
  enum BufferFactory {
    EMPTY {
      @Override Buffer newBuffer() {
        return new Buffer();
      }
    },

    SMALL_BUFFER {
      @Override Buffer newBuffer() {
        return new Buffer().writeUtf8("abcde");
      }
    },

    SMALL_SEGMENTED_BUFFER {
      @Override Buffer newBuffer() throws Exception {
        return bufferWithSegments("abc", "defg", "hijkl");
      }
    },

    LARGE_BUFFER {
      @Override Buffer newBuffer() throws Exception {
        Random dice = new Random(0);
        byte[] largeByteArray = new byte[512 * 1024];
        dice.nextBytes(largeByteArray);

        return new Buffer().write(largeByteArray);
      }
    },

    LARGE_BUFFER_WITH_RANDOM_LAYOUT {
      @Override Buffer newBuffer() throws Exception {
        Random dice = new Random(0);
        byte[] largeByteArray = new byte[512 * 1024];
        dice.nextBytes(largeByteArray);

        return bufferWithRandomSegmentLayout(dice, largeByteArray);
      }
    };

    abstract Buffer newBuffer() throws Exception;
  }

  @Parameters(name = "{0}")
  public static List<Object[]> parameters() throws Exception {
    List<Object[]> result = new ArrayList<>();
    for (BufferFactory bufferFactory : BufferFactory.values()) {
      result.add(new Object[] { bufferFactory });
    }
    return result;
  }

  @Parameter public BufferFactory bufferFactory;

  @Test public void apiExample() throws Exception {
    Buffer buffer = new Buffer();

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.resizeBuffer(1000_000);

      do {
        Arrays.fill(cursor.data, cursor.start, cursor.end, (byte) 'x');
      } while (cursor.next() != -1);

      cursor.seek(3);
      cursor.data[cursor.start] = 'o';

      cursor.seek(1);
      cursor.data[cursor.start] = 'o';

      cursor.resizeBuffer(4);
    }

    assertEquals(new Buffer().writeUtf8("xoxo"), buffer);
  }

  @Test public void accessSegmentBySegment() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      Buffer actual = new Buffer();
      while (cursor.next() != -1L) {
        actual.write(cursor.data, cursor.start, cursor.end - cursor.start);
      }
      assertEquals(buffer, actual);
    }
  }

  @Test public void seekToNegativeOneSeeksBeforeFirstSegment() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      cursor.seek(-1L);
      assertEquals(-1, cursor.offset);
      assertEquals(null, cursor.data);
      assertEquals(-1, cursor.start);
      assertEquals(-1, cursor.end);

      cursor.next();
      assertEquals(0, cursor.offset);
    }
  }

  @Test public void accessByteByByte() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      byte[] actual = new byte[(int) buffer.size()];
      for (int i = 0; i < buffer.size(); i++) {
        cursor.seek(i);
        actual[i] = cursor.data[cursor.start];
      }
      assertEquals(ByteString.of(actual), buffer.snapshot());
    }
  }

  @Test public void accessByteByByteReverse() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    try (UnsafeCursor cursor = buffer.readUnsafe()) {
    byte[] actual = new byte[(int) buffer.size()];
      for (int i = (int) (buffer.size() - 1); i >= 0; i--) {
        cursor.seek(i);
        actual[i] = cursor.data[cursor.start];
      }
      assertEquals(ByteString.of(actual), buffer.snapshot());
    }
  }

  @Test public void accessByteByByteAlwaysResettingToZero() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      byte[] actual = new byte[(int) buffer.size()];
      for (int i = 0; i < buffer.size(); i++) {
        cursor.seek(i);
        actual[i] = cursor.data[cursor.start];
        cursor.seek(0L);
      }
      assertEquals(ByteString.of(actual), buffer.snapshot());
    }
  }

  @Test public void segmentBySegmentNavigation() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    UnsafeCursor cursor = buffer.readUnsafe();
    assertEquals(-1, cursor.offset);
    try {
      long lastOffset = cursor.offset;
      while (cursor.next() != -1L) {
        assertTrue(cursor.offset > lastOffset);
        lastOffset = cursor.offset;
      }
      assertEquals(buffer.size(), cursor.offset);
      assertNull(cursor.data);
      assertEquals(-1, cursor.start);
      assertEquals(-1, cursor.end);
    } finally {
      cursor.close();
    }
  }

  @Test public void seekWithinSegment() throws Exception {
    assumeTrue(bufferFactory == BufferFactory.SMALL_SEGMENTED_BUFFER);
    Buffer buffer = bufferFactory.newBuffer();
    assertEquals("abcdefghijkl", buffer.clone().readUtf8());

    // Seek to the 'f' in the "defg" segment.
    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      assertEquals(2, cursor.seek(5)); // 2 for 2 bytes left in the segment: "fg".
      assertEquals(5, cursor.offset);
      assertEquals(2, cursor.end - cursor.start);
      assertEquals('d', (char) cursor.data[cursor.start - 2]); // Out of bounds!
      assertEquals('e', (char) cursor.data[cursor.start - 1]); // Out of bounds!
      assertEquals('f', (char) cursor.data[cursor.start]);
      assertEquals('g', (char) cursor.data[cursor.start + 1]);
    }
  }

  @Test public void acquireAndRelease() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    UnsafeCursor cursor = new UnsafeCursor();

    // Nothing initialized before acquire.
    assertEquals(-1, cursor.offset);
    assertNull(cursor.data);
    assertEquals(-1, cursor.start);
    assertEquals(-1, cursor.end);

    buffer.readUnsafe(cursor);
    cursor.close();

    // Nothing initialized after close.
    assertEquals(-1, cursor.offset);
    assertNull(cursor.data);
    assertEquals(-1, cursor.start);
    assertEquals(-1, cursor.end);
  }

  @Test public void doubleAcquire() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      buffer.readUnsafe(cursor);
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test public void releaseWithoutAcquire() throws Exception {
    UnsafeCursor cursor = new UnsafeCursor();
    try {
      cursor.close();
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test public void releaseAfterRelease() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    UnsafeCursor cursor = buffer.readUnsafe();
    cursor.close();
    try {
      cursor.close();
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test public void enlarge() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();

    Buffer expected = deepCopy(buffer);
    expected.writeUtf8("abc");

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      assertEquals(originalSize, cursor.resizeBuffer(originalSize + 3));
      cursor.seek(originalSize);
      cursor.data[cursor.start] = 'a';
      cursor.seek(originalSize + 1);
      cursor.data[cursor.start] = 'b';
      cursor.seek(originalSize + 2);
      cursor.data[cursor.start] = 'c';
    }

    assertEquals(expected, buffer);
  }

  @Test public void enlargeByManySegments() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();

    Buffer expected = deepCopy(buffer);
    expected.writeUtf8(TestUtil.repeat('x', 1_000_000));

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.resizeBuffer(originalSize + 1_000_000);
      cursor.seek(originalSize);
      do {
        Arrays.fill(cursor.data, cursor.start, cursor.end, (byte) 'x');
      } while (cursor.next() != -1);
    }

    assertEquals(expected, buffer);
  }

  @Test public void resizeNotAcquired() throws Exception {
    UnsafeCursor cursor = new UnsafeCursor();
    try {
      cursor.resizeBuffer(10);
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test public void expandNotAcquired() throws Exception {
    UnsafeCursor cursor = new UnsafeCursor();
    try {
      cursor.expandBuffer(10);
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test public void resizeAcquiredReadOnly() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();

    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      cursor.resizeBuffer(10);
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test public void expandAcquiredReadOnly() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();

    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      cursor.expandBuffer(10);
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test public void shrink() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    assumeTrue(buffer.size() > 3);
    long originalSize = buffer.size();

    Buffer expected = new Buffer();
    deepCopy(buffer).copyTo(expected, 0, originalSize - 3);

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      assertEquals(originalSize, cursor.resizeBuffer(originalSize - 3));
    }

    assertEquals(expected, buffer);
  }

  @Test public void shrinkByManySegments() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    assumeTrue(buffer.size() <= 1_000_000);
    long originalSize = buffer.size();

    Buffer toShrink = new Buffer();
    toShrink.writeUtf8(TestUtil.repeat('x', 1_000_000));
    deepCopy(buffer).copyTo(toShrink, 0, originalSize);

    UnsafeCursor cursor = new UnsafeCursor();
    toShrink.readAndWriteUnsafe(cursor);
    try {
      cursor.resizeBuffer(originalSize);
    } finally {
      cursor.close();
    }

    Buffer expected = new Buffer();
    expected.writeUtf8(TestUtil.repeat('x', (int) originalSize));
    assertEquals(expected, toShrink);
  }

  @Test public void shrinkAdjustOffset() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    assumeTrue(buffer.size() > 4);

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(buffer.size() - 1);
      cursor.resizeBuffer(3);
      assertEquals(3, cursor.offset);
      assertEquals(null, cursor.data);
      assertEquals(-1, cursor.start);
      assertEquals(-1, cursor.end);
    }
  }

  @Test public void resizeToSameSizeSeeksToEnd() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(buffer.size() / 2);
      assertEquals(originalSize, buffer.size());
      cursor.resizeBuffer(originalSize);
      assertEquals(originalSize, buffer.size());
      assertEquals(originalSize, cursor.offset);
      assertNull(cursor.data);
      assertEquals(-1, cursor.start);
      assertEquals(-1, cursor.end);
    }
  }

  @Test public void resizeEnlargeMovesCursorToOldSize() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();

    Buffer expected = deepCopy(buffer);
    expected.writeUtf8("a");

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(buffer.size() / 2);
      assertEquals(originalSize, buffer.size());
      cursor.resizeBuffer(originalSize + 1);
      assertEquals(originalSize, cursor.offset);
      assertNotNull(cursor.data);
      assertNotEquals(-1, cursor.start);
      assertEquals(cursor.start + 1, cursor.end);
      cursor.data[cursor.start] = 'a';
    }

    assertEquals(expected, buffer);
  }

  @Test public void resizeShrinkMovesCursorToEnd() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    assumeTrue(buffer.size() > 0);
    long originalSize = buffer.size();

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(buffer.size() / 2);
      assertEquals(originalSize, buffer.size());
      cursor.resizeBuffer(originalSize - 1);
      assertEquals(originalSize - 1, cursor.offset);
      assertNull(cursor.data);
      assertEquals(-1, cursor.start);
      assertEquals(-1, cursor.end);
    }
  }

  @Test public void acquireReadOnlyDoesNotCopySharedDataArray() throws Exception {
    Buffer buffer = deepCopy(bufferFactory.newBuffer());
    assumeTrue(buffer.size() > 0);

    Buffer shared = buffer.clone();
    assertTrue(buffer.head.shared);

    try (UnsafeCursor cursor = buffer.readUnsafe()) {
      cursor.seek(0);
      assertSame(cursor.data, shared.head.data);
    }
  }

  @Test public void acquireReadWriteDoesNotCopyUnsharedDataArray() throws Exception {
    Buffer buffer = deepCopy(bufferFactory.newBuffer());
    assumeTrue(buffer.size() > 0);
    assertFalse(buffer.head.shared);

    byte[] originalData = buffer.head.data;

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(0);
      assertSame(cursor.data, originalData);
    }
  }

  @Test public void acquireReadWriteCopiesSharedDataArray() throws Exception {
    Buffer buffer = deepCopy(bufferFactory.newBuffer());
    assumeTrue(buffer.size()>1);

    Buffer shared = buffer.clone();
    assertNotNull(buffer.head);
    assertTrue(buffer.head.shared);

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(0);
      assertNotSame(cursor.data, shared.head.data);
    }
  }

  @Test public void writeSharedSegments() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();

    // Make a deep copy. This buffer's segments are not shared.
    Buffer deepCopy = deepCopy(buffer);
    assertTrue(deepCopy.head == null || !deepCopy.head.shared);

    // Make a shallow copy. Both buffers' segments are shared as a side effect.
    Buffer shallowCopy = buffer.clone();
    assertTrue(shallowCopy.head == null || shallowCopy.head.shared);
    assertTrue(buffer.head == null || buffer.head.shared);

    Buffer expected = new Buffer();
    expected.writeUtf8(TestUtil.repeat('x', (int) buffer.size()));

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      while (cursor.next() != -1) {
        Arrays.fill(cursor.data, cursor.start, cursor.end, (byte) 'x');
      }
    }

    // The buffer was fully changed.
    assertEquals(expected, buffer);

    // The buffer we're shared with is unchanged.
    assertEquals(deepCopy, shallowCopy);
  }

  /** As an optimization it's okay to use the same cursor on multiple buffers. */
  @Test public void cursorReuse() throws Exception {
    UnsafeCursor cursor = new UnsafeCursor();

    Buffer buffer1 = bufferFactory.newBuffer();
    buffer1.readUnsafe(cursor);
    assertSame(buffer1, cursor.buffer);
    assertFalse(cursor.readWrite);
    cursor.close();
    assertSame(null, cursor.buffer);

    Buffer buffer2 = bufferFactory.newBuffer();
    buffer2.readAndWriteUnsafe(cursor);
    assertSame(buffer2, cursor.buffer);
    assertTrue(cursor.readWrite);
    cursor.close();
    assertSame(null, cursor.buffer);
  }

  @Test public void expand() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();

    Buffer expected = deepCopy(buffer);
    expected.writeUtf8("abcde");

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.expandBuffer(5);

      for (int i = 0; i < 5; i++) {
        cursor.data[cursor.start + i] = (byte) ('a' + i);
      }

      cursor.resizeBuffer(originalSize + 5);
    }

    assertEquals(expected, buffer);
  }

  @Test public void expandSameSegment() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();
    assumeTrue(originalSize > 0);

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(originalSize - 1);
      int originalEnd = cursor.end;
      assumeTrue(originalEnd < Segment.SIZE);

      long addedByteCount = cursor.expandBuffer(1);
      assertEquals(Segment.SIZE - originalEnd, addedByteCount);

      assertEquals(originalSize + addedByteCount, buffer.size());
      assertEquals(originalSize, cursor.offset);
      assertEquals(originalEnd, cursor.start);
      assertEquals(Segment.SIZE, cursor.end);
    }
  }

  @Test public void expandNewSegment() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      long addedByteCount = cursor.expandBuffer(Segment.SIZE);
      assertEquals(Segment.SIZE, addedByteCount);

      assertEquals(originalSize, cursor.offset);
      assertEquals(0, cursor.start);
      assertEquals(Segment.SIZE, cursor.end);
    }
  }

  @Test public void expandMovesOffsetToOldSize() throws Exception {
    Buffer buffer = bufferFactory.newBuffer();
    long originalSize = buffer.size();

    try (UnsafeCursor cursor = buffer.readAndWriteUnsafe()) {
      cursor.seek(buffer.size() / 2);
      assertEquals(originalSize, buffer.size());
      long addedByteCount = cursor.expandBuffer(5);
      assertEquals(originalSize + addedByteCount, buffer.size());
      assertEquals(originalSize, cursor.offset);
    }
  }

  /** Returns a copy of {@code buffer} with no segments with {@code original}. */
  private Buffer deepCopy(Buffer original) {
    Buffer result = new Buffer();
    if (original.size() == 0) return result;

    result.head = original.head.unsharedCopy();
    result.head.next = result.head.prev = result.head;
    for (Segment s = original.head.next; s != original.head; s = s.next) {
      result.head.prev.push(s.unsharedCopy());
    }
    result.size = original.size;

    return result;
  }
}
